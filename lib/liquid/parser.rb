# frozen_string_literal: true

module Liquid
  class Parser
    def initialize(input, expression_cache = nil)
      @ss = input.is_a?(StringScanner) ? input : StringScanner.new(input)
      @cache = expression_cache
      @tokens = Lexer.tokenize(@ss)
      @p      = 0 # pointer to current location
    end

    def jump(point)
      @p = point
    end

    # Consumes a token of specific type.
    # Throws SyntaxError if token doesn't match type expectation.
    def consume(type = nil)
      token = @tokens[@p]
      if type && token[0] != type
        raise SyntaxError, "Expected #{type} but found #{@tokens[@p].first}"
      end
      @p += 1
      token[1]
    end

    # Only consumes the token if it matches the type
    # Returns the token's contents if it was consumed
    # or false otherwise.
    def consume?(type)
      token = @tokens[@p]
      return false unless token && token[0] == type
      @p += 1
      token[1]
    end

    # Like consume? Except for an :id token of a certain name
    def id?(str)
      token = @tokens[@p]
      return false unless token && token[0] == :id
      return false unless token[1] == str
      @p += 1
      token[1]
    end

    # Peeks the ahead token, returning true if matching expectation
    def look(type, ahead = 0)
      tok = @tokens[@p + ahead]
      return false unless tok
      tok[0] == type
    end

    # expression := logical
    # logical    := equality (("and" | "or") equality)*
    # equality   := comparison (("==" | "!=" | "<>") comparison)*
    # comparison := primary ((">=" | ">" | "<" | "<=" | ... ) primary)*
    # primary    := string | number | variable_lookup | range | boolean | grouping
    def expression
      logical
    end

    # Logical relations in Liquid, unlike other languages, are right-to-left
    # associative. This creates a right-leaning tree and is why the method
    # looks a bit more complicated
    #
    # `a and b or c` is evaluated like (a and (b or c))
    # logical := equality (("and" | "or") equality)*
    def logical
      operator = nil
      expr = equality
      expr = BinaryExpression.new(expr, operator, equality) if (operator = consume?(:logical))
      expr.right_node = BinaryExpression.new(expr.right_node, operator, equality) while (operator = consume?(:logical))
      expr
    end

    # equality := comparison (("==" | "!=" | "<>") comparison)*
    def equality
      expr = comparison
      while look(:equality)
        operator = consume
        expr = BinaryExpression.new(expr, operator, comparison)
      end
      expr
    end

    # comparison := primary ((">=" | ">" | "<" | "<=" | ... ) primary)*
    def comparison
      expr = primary
      while look(:comparison)
        operator = consume
        expr = BinaryExpression.new(expr, operator, primary)
      end
      expr
    end

    # primary := string | number | variable_lookup | range | boolean | grouping
    def primary
      token = @tokens[@p]
      case token[0]
      when :id
        variable_lookup_or_literal
      when :open_square
        unnamed_variable_lookup
      when :string
        string
      when :number
        number
      when :open_round
        grouping_or_range_lookup
      else
        raise SyntaxError, "#{token} is not a valid expression"
      end
    end

    def number
      num = consume(:number)
      Expression.parse_number(num)
    end

    def string
      consume(:string)[1..-2]
    end

    # variable_lookup := id (lookup)*
    # lookup          := indexed_lookup | dot_lookup
    # indexed_lookup  := "[" expression "]"
    # dot_lookup      := "." id
    def variable_lookup
      name = consume(:id)
      lookups, command_flags = variable_lookups
      VariableLookup.new(name, lookups, command_flags)
    end

    # a variable_lookup without lookups could be a literal
    def variable_lookup_or_literal
      name = consume(:id)
      lookups, command_flags = variable_lookups
      if Expression::LITERALS.key?(name) && lookups.empty?
        Expression::LITERALS[name]
      else
        VariableLookup.new(name, lookups, command_flags)
      end
    end

    # unnamed_variable_lookup := indexed_lookup (lookup)*
    def unnamed_variable_lookup
      name = indexed_lookup
      lookups, command_flags = variable_lookups
      VariableLookup.new(name, lookups, command_flags)
    end

    # Parenthesized expressions are recursive
    # grouping     := "(" expression ")"
    def grouping_or_range_lookup
      consume(:open_round)
      expr = expression
      if consume?(:dotdot)
        RangeLookup.create(expr, expression)
      else
        expr
      end
    ensure
      consume(:close_round)
    end

    # range_lookup := "(" expression ".." expression ")"
    def range_lookup
      consume(:open_round)
      first = expression
      consume(:dotdot)
      last = expression
      consume(:close_round)
      RangeLookup.create(first, last)
    end

    def expression_string
      token = @tokens[@p]
      case token[0]
      when :id
        str = consume
        str << variable_lookups_string
      when :open_square
        str = consume.dup
        str << expression_string
        str << consume(:close_square)
        str << variable_lookups_string
      when :string, :number
        consume
      when :open_round
        consume
        first = expression_string
        consume(:dotdot)
        last = expression_string
        consume(:close_round)
        "(#{first}..#{last})"
      else
        raise SyntaxError, "#{token} is not a valid expression"
      end
    end

    def argument_string
      str = +""
      # might be a keyword argument (identifier: expression)
      if look(:id) && look(:colon, 1)
        str << consume << consume << ' '
      end

      str << expression_string
      str
    end

    def variable_lookups_string
      str = +""
      loop do
        if look(:open_square)
          str << consume
          str << expression_string
          str << consume(:close_square)
        elsif look(:dot)
          str << consume
          str << consume(:id)
        else
          break
        end
      end
      str
    end

    # Assumes safe input. For cases where you need the string.
    # Don't use this unless you're sure about what you're doing.
    def unsafe_parse_expression(markup)
      parse_expression(markup)
    end

    private

    def parse_expression(markup)
      Expression.parse(markup, @ss, @cache)
    end

    def variable_lookups
      lookups = []
      command_flags = 0
      i = -1
      loop do
        i += 1
        if look(:open_square)
          lookups << indexed_lookup
        elsif consume?(:dot)
          lookup = consume(:id)
          lookups << lookup
          command_flags |= 1 << i if VariableLookup::COMMAND_METHODS.include?(lookup)
        else
          break
        end
      end
      [lookups, command_flags]
    end

    def indexed_lookup
      consume(:open_square)
      expr = expression
      consume(:close_square)
      expr
    end
  end
end
