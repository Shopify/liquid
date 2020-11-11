# frozen_string_literal: true

module Liquid
  class Parser
    def initialize(input)
      l       = Lexer.new(input)
      @tokens = l.tokenize
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

    def expression
      token = @tokens[@p]
      case token[0]
      when :id
        if Expression::LITERALS.key?(token[1]) && !look(:dot, 1) && !look(:open_square, 1)
          Expression::LITERALS[consume]
        else
          VariableLookup.strict_parse(self)
        end
      when :open_square
        VariableLookup.strict_parse(self)
      when :string
        consume[1..-2]
      when :number
        Expression.parse(consume)
      when :open_round
        consume
        first = expression
        consume(:dotdot)
        last = expression
        consume(:close_round)
        if first.respond_to?(:evaluate) || last.respond_to?(:evaluate)
          RangeLookup.new(first, last)
        else
          first.to_i..last.to_i
        end
      else
        raise SyntaxError, "#{token} is not a valid expression"
      end
    end

    def arguments
      filter_args = []
      keyword_args = nil

      loop do
        # keyword argument (identifier: expression)
        if look(:colon, 1)
          keyword_args ||= {}
          k = consume(:id)
          consume
          v = expression
          keyword_args[k] = v
        else
          filter_args << expression
        end

        break unless consume?(:comma)
      end

      result = [filter_args]
      result << keyword_args if keyword_args
      result
    end
  end
end
