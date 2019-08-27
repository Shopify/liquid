# frozen_string_literal: true

module Liquid
  class BlockBody
    FULL_TOKEN = /\A#{TAG_START}#{WHITESPACE_CONTROL}?\s*(\w+)\s*(.*?)#{WHITESPACE_CONTROL}?#{TAG_END}\z/om.freeze
    CONTENT_OF_VARIABLE = /\A#{VARIABLE_START}#{WHITESPACE_CONTROL}?(.*?)#{WHITESPACE_CONTROL}?#{VARIABLE_END}\z/om.freeze
    WHITESPACE_OR_NOTHING = /\A\s*\z/.freeze
    TAG_START = '{%'
    VAR_START = '{{'

    attr_reader :nodelist

    def initialize
      @nodelist = []
      @blank = true
    end

    def parse(tokenizer, parse_context)
      parse_context.line_number = tokenizer.line_number
      while (token = tokenizer.shift)
        next if token.empty?

        case
        when token.start_with?(TAG_START)
          whitespace_handler(token, parse_context)
          raise_missing_tag_terminator(token, parse_context) unless token =~ FULL_TOKEN
          tag_name = Regexp.last_match(1)
          markup = Regexp.last_match(2)
          # fetch the tag from registered blocks
          unless (tag = registered_tags[tag_name])
            # end parsing if we reach an unknown tag and let the caller decide
            # determine how to proceed
            return yield tag_name, markup
          end

          new_tag = tag.parse(tag_name, markup, tokenizer, parse_context)
          @blank &&= new_tag.blank?
          @nodelist << new_tag
        when token.start_with?(VAR_START)
          whitespace_handler(token, parse_context)
          @nodelist << create_variable(token, parse_context)
          @blank = false
        else
          token.lstrip! if parse_context.trim_whitespace
          parse_context.trim_whitespace = false
          @nodelist << token
          @blank &&= token.match?(WHITESPACE_OR_NOTHING)
        end
        parse_context.line_number = tokenizer.line_number
      end

      yield nil, nil
    end

    def whitespace_handler(token, parse_context)
      if token[2] == WHITESPACE_CONTROL
        previous_token = @nodelist.last
        previous_token.rstrip! if previous_token.is_a?(String)
      end
      parse_context.trim_whitespace = (token[-3] == WHITESPACE_CONTROL)
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
      node.render_to_output_buffer(context, output)
    rescue UndefinedVariable, UndefinedDropMethod, UndefinedFilter => e
      context.handle_error(e, node.line_number)
    rescue ::StandardError => e
      line_number = node.is_a?(String) ? nil : node.line_number
      output << context.handle_error(e, line_number)
    end

    def raise_if_resource_limits_reached(context, length)
      context.resource_limits.render_length += length
      return unless context.resource_limits.reached?

      raise MemoryError, 'Memory limits exceeded'
    end

    def create_variable(token, parse_context)
      token.scan(CONTENT_OF_VARIABLE) do |content|
        markup = content.first
        return Variable.new(markup, parse_context)
      end
      raise_missing_variable_terminator(token, parse_context)
    end

    def raise_missing_tag_terminator(token, parse_context)
      raise SyntaxError, parse_context.locale.t('errors.syntax.tag_termination', token: token, tag_end: TAG_END.inspect)
    end

    def raise_missing_variable_terminator(token, parse_context)
      raise SyntaxError, parse_context.locale.t('errors.syntax.variable_termination', token: token, tag_end: VARIABLE_END.inspect)
    end

    def registered_tags
      Template.tags
    end
  end
end
