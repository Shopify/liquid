module Liquid
  class Case < Block
    Syntax     = /(#{QuotedFragment})/o
    WhenSyntax = /(#{QuotedFragment})(?:(?:\s+or\s+|\s*\,\s*)(#{QuotedFragment}.*))?/om

    attr_reader :blocks, :left

    def initialize(tag_name, markup, options)
      super
      @blocks = []

      if markup =~ Syntax
        @left = Expression.parse(Regexp.last_match(1))
      else
        raise SyntaxError, options[:locale].t("errors.syntax.case".freeze)
      end
    end

    def parse(tokens)
      body = BlockBody.new
      body = @blocks.last.attachment while parse_body(body, tokens)
    end

    def nodelist
      @blocks.map(&:attachment)
    end

    def unknown_tag(tag, markup, tokens)
      case tag
      when 'when'.freeze
        record_when_condition(markup)
      when 'else'.freeze
        record_else_condition(markup)
      else
        super
      end
    end

    def render_to_output_buffer(context, output)
      context.stack do
        execute_else_block = true

        @blocks.each do |block|
          if block.else?
            block.attachment.render_to_output_buffer(context, output) if execute_else_block
          elsif block.evaluate(context)
            execute_else_block = false
            block.attachment.render_to_output_buffer(context, output)
          end
        end
      end

      output
    end

    private

    def record_when_condition(markup)
      body = BlockBody.new

      while markup
        unless markup =~ WhenSyntax
          raise SyntaxError, options[:locale].t("errors.syntax.case_invalid_when".freeze)
        end

        markup = Regexp.last_match(2)

        block = Condition.new(@left, '=='.freeze, Expression.parse(Regexp.last_match(1)))
        block.attach(body)
        @blocks << block
      end
    end

    def record_else_condition(markup)
      unless markup.strip.empty?
        raise SyntaxError, options[:locale].t("errors.syntax.case_invalid_else".freeze)
      end

      block = ElseCondition.new
      block.attach(BlockBody.new)
      @blocks << block
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.left] + @node.blocks
      end
    end
  end

  Template.register_tag('case'.freeze, Case)
end
