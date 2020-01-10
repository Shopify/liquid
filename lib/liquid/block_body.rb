# frozen_string_literal: true

require 'English'

module Liquid
  class BlockBody
    LiquidTagToken      = /\A\s*(\w+)\s*(.*?)\z/o
    FullToken           = /\A#{TagStart}#{WhitespaceControl}?(\s*)(\w+)(\s*)(.*?)#{WhitespaceControl}?#{TagEnd}\z/om
    ContentOfVariable   = /\A#{VariableStart}#{WhitespaceControl}?(.*?)#{WhitespaceControl}?#{VariableEnd}\z/om
    WhitespaceOrNothing = /\A\s*\z/
    TAGSTART            = "{%"
    VARSTART            = "{{"

    attr_reader :nodelist

    def initialize
      @nodelist = []
      @blank    = true
    end

    def parse(tokenizer, parse_context, &block)
      parse_context.line_number = tokenizer.line_number

      if tokenizer.for_liquid_tag
        parse_for_liquid_tag(tokenizer, parse_context, &block)
      else
        parse_for_document(tokenizer, parse_context, &block)
      end
    end

    private def parse_for_liquid_tag(tokenizer, parse_context)
      while (token = tokenizer.shift)
        unless token.empty? || token =~ WhitespaceOrNothing
          unless token =~ LiquidTagToken
            # line isn't empty but didn't match tag syntax, yield and let the
            # caller raise a syntax error
            return yield token, token
          end
          tag_name = Regexp.last_match(1)
          markup   = Regexp.last_match(2)
          unless (tag = registered_tags[tag_name])
            # end parsing if we reach an unknown tag and let the caller decide
            # determine how to proceed
            return yield tag_name, markup
          end
          new_tag = tag.parse(tag_name, markup, tokenizer, parse_context)
          @blank &&= new_tag.blank?
          @nodelist << new_tag
        end
        parse_context.line_number = tokenizer.line_number
      end

      yield nil, nil
    end

    # @api private
    def self.unknown_tag_in_liquid_tag(end_tag_name, end_tag_markup)
      yield end_tag_name, end_tag_markup
    ensure
      Usage.increment("liquid_tag_contains_outer_tag") unless $ERROR_INFO.is_a?(SyntaxError)
    end

    private def parse_liquid_tag(markup, parse_context, &block)
      liquid_tag_tokenizer = Tokenizer.new(markup, line_number: parse_context.line_number, for_liquid_tag: true)
      parse_for_liquid_tag(liquid_tag_tokenizer, parse_context) do |end_tag_name, end_tag_markup|
        next unless end_tag_name
        self.class.unknown_tag_in_liquid_tag(end_tag_name, end_tag_markup, &block)
      end
    end

    private def parse_for_document(tokenizer, parse_context, &block)
      while (token = tokenizer.shift)
        next if token.empty?
        case
        when token.start_with?(TAGSTART)
          whitespace_handler(token, parse_context)
          unless token =~ FullToken
            raise_missing_tag_terminator(token, parse_context)
          end
          tag_name = Regexp.last_match(2)
          markup   = Regexp.last_match(4)

          if parse_context.line_number
            # newlines inside the tag should increase the line number,
            # particularly important for multiline {% liquid %} tags
            parse_context.line_number += Regexp.last_match(1).count("\n") + Regexp.last_match(3).count("\n")
          end

          if tag_name == 'liquid'
            parse_liquid_tag(markup, parse_context, &block)
            next
          end

          unless (tag = registered_tags[tag_name])
            # end parsing if we reach an unknown tag and let the caller decide
            # determine how to proceed
            return yield tag_name, markup
          end
          new_tag = tag.parse(tag_name, markup, tokenizer, parse_context)
          @blank &&= new_tag.blank?
          @nodelist << new_tag
        when token.start_with?(VARSTART)
          whitespace_handler(token, parse_context)
          @nodelist << create_variable(token, parse_context)
          @blank = false
        else
          if parse_context.trim_whitespace
            token.lstrip!
          end
          parse_context.trim_whitespace = false
          @nodelist << token
          @blank &&= !!(token =~ WhitespaceOrNothing)
        end
        parse_context.line_number = tokenizer.line_number
      end

      yield nil, nil
    end

    def whitespace_handler(token, parse_context)
      if token[2] == WhitespaceControl
        previous_token = @nodelist.last
        if previous_token.is_a?(String)
          previous_token.rstrip!
        end
      end
      parse_context.trim_whitespace = (token[-3] == WhitespaceControl)
    end

    def blank?
      @blank
    end

    def render(context)
      render_to_output_buffer(context, +'')
    end

    def render_to_output_buffer(context, output)
      context.resource_limits.render_score += @nodelist.length

      idx = 0
      while (node = @nodelist[idx])
        previous_output_size = output.bytesize

        case node
        when String
          output << node
        when Variable
          render_node(context, output, node)
        when Block
          render_node(context, node.blank? ? +'' : output, node)
          break if context.interrupt? # might have happened in a for-block
        when Continue, Break
          # If we get an Interrupt that means the block must stop processing. An
          # Interrupt is any command that stops block execution such as {% break %}
          # or {% continue %}
          context.push_interrupt(node.interrupt)
          break
        else # Other non-Block tags
          render_node(context, output, node)
          break if context.interrupt? # might have happened through an include
        end
        idx += 1

        raise_if_resource_limits_reached(context, output.bytesize - previous_output_size)
      end

      output
    end

    private

    def render_node(context, output, node)
      if node.disabled?(context)
        output << node.disabled_error_message
        return
      end
      disable_tags(context, node.disabled_tags) do
        node.render_to_output_buffer(context, output)
      end
    rescue UndefinedVariable, UndefinedDropMethod, UndefinedFilter => e
      context.handle_error(e, node.line_number)
    rescue ::StandardError => e
      line_number = node.is_a?(String) ? nil : node.line_number
      output << context.handle_error(e, line_number)
    end

    def disable_tags(context, tags, &block)
      return yield if tags.empty?
      context.registers[:disabled_tags].disable(tags, &block)
    end

    def raise_if_resource_limits_reached(context, length)
      context.resource_limits.render_length += length
      return unless context.resource_limits.reached?
      raise MemoryError, "Memory limits exceeded"
    end

    def create_variable(token, parse_context)
      token.scan(ContentOfVariable) do |content|
        markup = content.first
        return Variable.new(markup, parse_context)
      end
      raise_missing_variable_terminator(token, parse_context)
    end

    def raise_missing_tag_terminator(token, parse_context)
      raise SyntaxError, parse_context.locale.t("errors.syntax.tag_termination", token: token, tag_end: TagEnd.inspect)
    end

    def raise_missing_variable_terminator(token, parse_context)
      raise SyntaxError, parse_context.locale.t("errors.syntax.variable_termination", token: token, tag_end: VariableEnd.inspect)
    end

    def registered_tags
      Template.tags
    end
  end
end
