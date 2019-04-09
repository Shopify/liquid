module Liquid
  # "While" loops a block until some condition no longer holds true.
  #
  class While < Block
    Syntax = /(#{QuotedFragment})\s*([=!<>a-z_]+)?\s*(#{QuotedFragment})?/o
    ExpressionsAndOperators = /(?:\b(?:\s?and\s?|\s?or\s?)\b|(?:\s*(?!\b(?:\s?and\s?|\s?or\s?)\b)(?:#{QuotedFragment}|\S+)\s*)+)/o
    BOOLEAN_OPERATORS = %w(and or).freeze

    attr_reader :condition

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
      @while_block = BlockBody.new
    end

    def parse(tokens)
      parse_body(@while_block, tokens)
    end

    def nodelist
      @while_block.nodelist
    end

    def render(context)
      result = ''

      context.stack do
        while @condition.evaluate(context) do
          result << @while_block.render(context)

          # Handle any interrupts if they exist.
          if context.interrupt?
            interrupt = context.pop_interrupt
            break if interrupt.is_a? BreakInterrupt
            next if interrupt.is_a? ContinueInterrupt
          end
        end
      end

      result
    end

    protected

    def lax_parse(markup)
      expressions = markup.scan(ExpressionsAndOperators)
      raise(SyntaxError.new(options[:locale].t("errors.syntax.while".freeze))) unless expressions.pop =~ Syntax

      condition = Condition.new(Expression.parse($1), $2, Expression.parse($3))

      until expressions.empty?
        operator = expressions.pop.to_s.strip

        raise(SyntaxError.new(options[:locale].t("errors.syntax.while".freeze))) unless expressions.pop.to_s =~ Syntax

        new_condition = Condition.new(Expression.parse($1), $2, Expression.parse($3))
        raise(SyntaxError.new(options[:locale].t("errors.syntax.while".freeze))) unless BOOLEAN_OPERATORS.include?(operator)
        new_condition.send(operator, condition)
        condition = new_condition
      end

      @condition = condition
    end

    def strict_parse(markup)
      p = Parser.new(markup)
      condition = parse_binary_comparisons(p)
      p.consume(:end_of_string)
      @condition = condition
    end

  private

    def parse_binary_comparisons(p)
      condition = parse_comparison(p)
      first_condition = condition
      while op = (p.id?('and'.freeze) || p.id?('or'.freeze))
        child_condition = parse_comparison(p)
        condition.send(op, child_condition)
        condition = child_condition
      end
      first_condition
    end

    def parse_comparison(p)
      a = Expression.parse(p.expression)
      if op = p.consume?(:comparison)
        b = Expression.parse(p.expression)
        Condition.new(a, op, b)
      else
        Condition.new(a)
      end
    end

  Template.register_tag('while'.freeze, While)

  end
end
