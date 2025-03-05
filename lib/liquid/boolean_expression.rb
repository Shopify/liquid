# frozen_string_literal: true

module Liquid
  class BooleanExpression
    def self.parse(markup, ss = StringScanner.new(""), cache = nil)
      markup = markup.strip

      # Handle parenthesized expressions first
      if markup.start_with?('(') && balance_parentheses(markup)
        # Find the matching closing parenthesis
        nesting = 0
        close_index = nil

        markup.chars.each_with_index do |char, i|
          if char == '('
            nesting += 1
          elsif char == ')'
            nesting -= 1
            if nesting == 0
              close_index = i
              break
            end
          end
        end

        if close_index && close_index < markup.length - 1
          # We have something like "(expr) rest"
          paren_expr = markup[1...close_index]
          rest = markup[close_index + 1..-1].strip

          # Check if rest starts with "and" or "or" (fixed the matching)
          if rest =~ /\A(and|or)\s+/i
            # Get the operator (and/or)
            operator = ::Regexp.last_match(1).downcase
            # Get the remaining part after the operator
            remaining = rest[operator.length..-1].strip

            left_condition = parse(paren_expr, ss, cache)
            right_condition = parse(remaining, ss, cache)

            condition = Condition.new(left_condition, nil, nil)
            if operator == 'and'
              condition.and(Condition.new(right_condition, nil, nil))
            else # operator == 'or'
              condition.or(Condition.new(right_condition, nil, nil))
            end

            return condition
          end
        elsif close_index == markup.length - 1
          # Just a parenthesized expression "(expr)"
          return parse(markup[1...close_index], ss, cache)
        end
      end

      # Check if we have something like "expr and (expr)"
      if (match = markup.match(/\A\s*(.+?)\s+(and|or)\s+\((.+)\)\s*\z/i))
        left_expr = match[1]
        operator = match[2].downcase
        right_expr = match[3]

        left_condition = parse(left_expr, ss, cache)
        right_condition = parse(right_expr, ss, cache)

        condition = Condition.new(left_condition, nil, nil)
        if operator == 'and'
          condition.and(Condition.new(right_condition, nil, nil))
        else # operator == 'or'
          condition.or(Condition.new(right_condition, nil, nil))
        end

        return condition
      end

      # First, try to handle OR operator (lower precedence)
      if (match = markup.match(/\A\s*(.+?)\s+or\s+(.+)\s*\z/i))
        left = parse(match[1], ss, cache)
        right = parse(match[2], ss, cache)

        # Create a condition for OR operation
        condition = Condition.new(left, nil, nil)
        condition.or(Condition.new(right, nil, nil))

        return condition
      end

      # Then try to handle AND operator (higher precedence)
      if (match = markup.match(/\A\s*(.+?)\s+and\s+(.+)\s*\z/i))
        left = parse(match[1], ss, cache)
        right = parse(match[2], ss, cache)

        # Create a condition for AND operation
        condition = Condition.new(left, nil, nil)
        condition.and(Condition.new(right, nil, nil))

        return condition
      end

      # Then try to parse as a comparison expression
      if (match = markup.match(/\A\s*(.+?)\s*(==|!=|<>|<=|>=|<|>|contains)\s*(.+)\s*\z/))
        left = Expression.parse(match[1], ss, cache)
        operator = match[2]
        right = Expression.parse(match[3], ss, cache)

        # Create a condition object to evaluate the expression
        condition = Condition.new(left, operator, right)
        return condition
      end

      # If no operator is found, just parse as regular expression
      Expression.parse(markup, ss, cache)
    end

    private

    def self.balance_parentheses(markup)
      nesting = 0
      markup.each_char do |char|
        if char == '('
          nesting += 1
        elsif char == ')'
          nesting -= 1
          return false if nesting < 0 # Unbalanced
        end
      end
      nesting == 0 # Should end with balanced parentheses
    end
  end
end
