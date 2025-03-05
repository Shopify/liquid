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

          last_expr = expressions.pop

          condition = if ComparisonExpression.comparison?(last_expr)
            ComparisonExpression.parse(last_expr, ss, cache)
          elsif logical?(last_expr)
            LogicalExpression.parse(last_expr, ss, cache)
          else
            Condition.new(Expression.parse(last_expr, ss, cache, true), nil, nil)
          end

          until expressions.empty?
            operator = expressions.pop.to_s.strip
            next unless boolean_operator?(operator)

            expr = expressions.pop.to_s.strip

            new_condition = if ComparisonExpression.comparison?(expr)
              ComparisonExpression.parse(expr, ss, cache)
            elsif logical?(expr)
              LogicalExpression.parse(expr, ss, cache)
            else
              Condition.new(Expression.parse(expr, ss, cache, true), nil, nil)
            end

            if operator == 'and'
              new_condition.and(condition)
            else # operator == 'or'
              new_condition.or(condition)
            end

            condition = new_condition
          end

          condition
        end
      end
    end
  end
end
