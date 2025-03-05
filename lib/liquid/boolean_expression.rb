# frozen_string_literal: true

module Liquid
  class BooleanExpression
    def self.parse(markup, ss = StringScanner.new(""), cache = nil)
      # Split the markup by comparison operators
      if (match = markup.match(/\A\s*(.+?)\s*(==|!=|<>|<=|>=|<|>|contains)\s*(.+)\s*\z/))
        left = Expression.parse(match[1], ss, cache)
        operator = match[2]
        right = Expression.parse(match[3], ss, cache)

        # Create a condition object to evaluate the expression
        condition = Condition.new(left, operator, right)
        return condition
      end

      # If no comparison operator is found, just parse as regular expression
      Expression.parse(markup, ss, cache)
    end
  end
end
