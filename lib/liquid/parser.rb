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

    def look(type, ahead = 0)
      tok = @tokens[@p + ahead]
      return false unless tok
      tok[0] == type
    end

    def expression_node
      parse_expression(expression_string)
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

    def variable_lookups
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

    def expression_string
      token = @tokens[@p]
      case token[0]
      when :id
        str = consume
        str << variable_lookups
      when :open_square
        str = consume.dup
        str << expression_string
        str << consume(:close_square)
        str << variable_lookups
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

    # Assumes safe input. For cases where you need the string.
    # Don't use this unless you're sure about what you're doing.
    def unsafe_parse_expression(markup)
      parse_expression(markup)
    end

    private

    def parse_expression(markup)
      Expression.parse(markup, @ss, @cache)
    end
  end
end
