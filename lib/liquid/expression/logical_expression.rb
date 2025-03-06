# frozen_string_literal: true

module Liquid
  class Expression
    class LogicalExpression
      LOGICAL_REGEX = /\A\s*(.+?)\s+(and|or)\s+(.+)\s*\z/i
      EXPRESSIONS_AND_OPERATORS = /(?:\b(?:\s?and\s?|\s?or\s?)\b|(?:\s*(?!\b(?:\s?and\s?|\s?or\s?)\b)(?:#{QuotedFragment}|\S+)\s*)+)/o
      BOOLEAN_OPERATORS = ['and', 'or'].freeze

      class << self
        def logical?(markup)
          markup.match(LOGICAL_REGEX)
        end

        def boolean_operator?(markup)
          BOOLEAN_OPERATORS.include?(markup)
        end

        def parse(markup, ss, cache)
          expressions = markup.scan(EXPRESSIONS_AND_OPERATORS)

          expression = expressions.pop
          condition  = parse_condition(expression, ss, cache)

          until expressions.empty?
            operator = expressions.pop.to_s.strip

            next unless boolean_operator?(operator)

            expression    = expressions.pop.to_s.strip
            new_condition = parse_condition(expression, ss, cache)

            case operator
            when 'and' then new_condition.and(condition)
            when 'or'  then new_condition.or(condition)
            end

            condition = new_condition
          end

          condition
        end

        private

        def parse_condition(expr, ss, cache)
          return ComparisonExpression.parse(expr, ss, cache) if comparison?(expr)
          return LogicalExpression.parse(expr, ss, cache)    if logical?(expr)

          Condition.new(Expression.parse(expr, ss, cache), nil, nil)
        end

        def comparison?(...)
          ComparisonExpression.comparison?(...)
        end
      end
    end
  end
end
