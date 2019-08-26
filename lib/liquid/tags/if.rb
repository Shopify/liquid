# frozen_string_literal: true

module Liquid
  # If is the conditional block
  #
  #   {% if user.admin %}
  #     Admin user!
  #   {% else %}
  #     Not admin user
  #   {% endif %}
  #
  #    There are {% if count < 5 %} less {% else %} more {% endif %} items than you need.
  #
  class If < Block
    SYNTAX = /(#{QUOTED_FRAGMENT})\s*([=!<>a-z_]+)?\s*(#{QUOTED_FRAGMENT})?/o.freeze
    EXPRESSIONS_AND_OPERATORS = /(?:\b(?:\s?and\s?|\s?or\s?)\b|(?:\s*(?!\b(?:\s?and\s?|\s?or\s?)\b)(?:#{QUOTED_FRAGMENT}|\S+)\s*)+)/o.freeze
    BOOLEAN_OPERATORS = %w[and or].freeze

    attr_reader :blocks

    def initialize(tag_name, markup, options)
      super
      @blocks = []
      push_block('if', markup)
    end

    def nodelist
      @blocks.map(&:attachment)
    end

    def parse(tokens)
      while parse_body(@blocks.last.attachment, tokens)
      end
    end

    def unknown_tag(tag, markup, tokens)
      if %w[elsif else].include?(tag)
        push_block(tag, markup)
      else
        super
      end
    end

    def render_to_output_buffer(context, output)
      context.stack do
        @blocks.each do |block|
          return block.attachment.render_to_output_buffer(context, output) if block.evaluate(context)
        end
      end

      output
    end

    private

    def push_block(tag, markup)
      block = if tag == 'else'
        ElseCondition.new
      else
        parse_with_selected_parser(markup)
      end

      @blocks.push(block)
      block.attach(BlockBody.new)
    end

    def lax_parse(markup)
      expressions = markup.scan(EXPRESSIONS_AND_OPERATORS)
      raise SyntaxError, options[:locale].t('errors.syntax.if') unless expressions.pop =~ SYNTAX

      condition = Condition.new(Expression.parse(Regexp.last_match(1)), Regexp.last_match(2), Expression.parse(Regexp.last_match(3)))

      until expressions.empty?
        operator = expressions.pop.to_s.strip

        raise SyntaxError, options[:locale].t('errors.syntax.if') unless expressions.pop.to_s =~ SYNTAX

        new_condition = Condition.new(Expression.parse(Regexp.last_match(1)), Regexp.last_match(2), Expression.parse(Regexp.last_match(3)))
        raise SyntaxError, options[:locale].t('errors.syntax.if') unless BOOLEAN_OPERATORS.include?(operator)

        new_condition.send(operator, condition)
        condition = new_condition
      end

      condition
    end

    def strict_parse(markup)
      p = Parser.new(markup)
      condition = parse_binary_comparisons(p)
      p.consume(:end_of_string)
      condition
    end

    def parse_binary_comparisons(p)
      condition = parse_comparison(p)
      first_condition = condition
      while (op = (p.id?('and') || p.id?('or')))
        child_condition = parse_comparison(p)
        condition.send(op, child_condition)
        condition = child_condition
      end
      first_condition
    end

    def parse_comparison(p)
      a = Expression.parse(p.expression)
      if (op = p.consume?(:comparison))
        b = Expression.parse(p.expression)
        Condition.new(a, op, b)
      else
        Condition.new(a)
      end
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        @node.blocks
      end
    end
  end

  Template.register_tag('if', If)
end
