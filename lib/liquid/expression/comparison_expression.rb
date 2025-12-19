# frozen_string_literal: true

module Liquid
  class Expression
    class ComparisonExpression
      # We can improve the resiliency of lax parsing by not expecting whitespace
      # surrounding the operator (ie \s+ => \s*).
      # However this is not in parity with existing lax parsing behavior.
      COMPARISON_REGEX = /\A\s*(.+?)\s+(==|!=|<>|<=|>=|<|>|contains)\s+(.+)\s*\z/

      class << self
        def comparison?(markup)
          markup.match(COMPARISON_REGEX)
        end

        def parse(markup, ss, cache)
          match = comparison?(markup)

          if match
            left = Condition.parse(match[1].strip, ss, cache)
            operator = match[2].strip
            right = Condition.parse(match[3].strip, ss, cache)
            return Condition.new(left, operator, right)
          end

          Condition.new(parse(markup, ss, cache), nil, nil)
        end
      end
    end
  end
end
