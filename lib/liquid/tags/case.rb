# frozen_string_literal: true

module Liquid
  class Case < Block
    Syntax     = /(#{QuotedFragment})/o
    WhenSyntax = /(#{QuotedFragment})(?:(?:\s+or\s+|\s*\,\s*)(#{QuotedFragment}.*))?/om

    attr_reader :blocks, :left

    def initialize(tag_name, markup, options)
      super
      @blocks = []

      if markup =~ Syntax
        @left = parse_expression(Regexp.last_match(1))
      else
        raise SyntaxError, options[:locale].t("errors.syntax.case")
      end
    end

    def parse(tokens)
      body = case_body = new_body
      body = @blocks.last.attachment while parse_body(body, tokens)
      @blocks.reverse_each do |condition|
        body = condition.attachment
        unless body.frozen?
          body.remove_blank_strings if blank?
          body.freeze
        end
      end
      case_body.freeze
    end

    def nodelist
      @blocks.map(&:attachment)
    end

    def unknown_tag(tag, markup, tokens)
      case tag
      when 'when'
        record_when_condition(markup)
      when 'else'
        record_else_condition(markup)
      else
        super
      end
    end

    def render_to_output_buffer(context, output)
      execute_else_block = true

      @blocks.each do |block|
        if block.else?
          block.attachment.render_to_output_buffer(context, output) if execute_else_block
        elsif block.evaluate(context)
          execute_else_block = false
          block.attachment.render_to_output_buffer(context, output)
        end
      end

      output
    end

    private

    def record_when_condition(markup)
      body = new_body

      while markup
        unless markup =~ WhenSyntax
          raise SyntaxError, options[:locale].t("errors.syntax.case_invalid_when")
        end

        markup = Regexp.last_match(2)

        block = Condition.new(@left, '==', Condition.parse_expression(parse_context, Regexp.last_match(1)))
        block.attach(body)
        @blocks << block
      end
    end

    def record_else_condition(markup)
      unless markup.strip.empty?
        raise SyntaxError, options[:locale].t("errors.syntax.case_invalid_else")
      end

      block = ElseCondition.new
      block.attach(new_body)
      @blocks << block
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.left] + @node.blocks
      end
    end
  end

  Template.register_tag('case', Case)
end
