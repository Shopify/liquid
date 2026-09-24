# frozen_string_literal: true

module Liquid
  class Parser
    def initialize(input, reject_bare_brackets: false, allow_calls: false)
      ss = input.is_a?(StringScanner) ? input : StringScanner.new(input)
      @tokens = Lexer.tokenize(ss)
      @p      = 0 # pointer to current location
      @reject_bare_brackets = reject_bare_brackets
      @allow_calls = allow_calls
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
        return callable_or_lookup if @allow_calls

        str = consume
        str << variable_lookups
      when :open_square
        if @reject_bare_brackets
          raise SyntaxError, "Bare bracket access is not allowed. Use #{Expression::SELF}['...'] instead"
        end
        str = consume.dup
        str << expression
        str << consume(:close_square)
        str << variable_lookups
      when :string, :number
        consume
      when :open_round
        consume
        first = expression
        consume(:dotdot)
        last = expression
        consume(:close_round)
        return RangeLookup.new(Expression.parse(first), Expression.parse(last)) unless first.is_a?(String) && last.is_a?(String)

        "(#{first}..#{last})"
      else
        raise SyntaxError, "#{token} is not a valid expression"
      end
    end

    def expression_with_markup
      start = @p
      # Parsing lookups appends to consumed identifier strings.
      markup_tokens = @tokens[start...-1].map { |token| token[1].dup }
      value = expression
      markup = value.is_a?(String) ? value : markup_tokens.take(@p - start).join
      [value, markup]
    end

    def remaining_markup
      @tokens[@p...-1].map { |token| token[1] }.join(' ')
    end

    def parameters
      parameters = []
      return parameters unless consume?(:open_round)

      unless look(:close_round)
        parameters << consume(:id)
        parameters << consume(:id) while consume?(:comma) && !look(:close_round)
      end
      consume(:close_round)
      raise SyntaxError, "Duplicate closure parameter" unless parameters.uniq.length == parameters.length

      parameters
    end

    def argument
      str = +""
      # might be a keyword argument (identifier: expression)
      if look(:id) && look(:colon, 1)
        str << consume << consume << ' '
      end

      str << expression
      str
    end

    def variable_lookups
      str = +""
      loop do
        if look(:open_square)
          str << consume
          str << expression
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

    private

    def callable_or_lookup
      target = callable_lookups(consume(:id))
      return target unless consume?(:open_round)

      arguments = []
      unless look(:close_round)
        arguments << Expression.parse(expression)
        arguments << Expression.parse(expression) while consume?(:comma) && !look(:close_round)
      end
      consume(:close_round)
      target = VariableLookup.parse(target) if target.is_a?(String)
      CallExpression.new(target, arguments)
    end

    def callable_lookups(target)
      loop do
        if consume?(:dot)
          target = append_lookup(target, consume(:id), command: true)
          next
        end
        break unless consume?(:open_square)

        key = expression
        consume(:close_square)
        target = append_lookup(target, key)
      end
      target
    end

    def append_lookup(target, key, command: false)
      if target.is_a?(String) && key.is_a?(String)
        return target << (command ? ".#{key}" : "[#{key}]")
      end

      target = VariableLookup.parse(target) if target.is_a?(String)
      target.add_lookup(command ? key : Expression.parse(key), command: command)
      target
    end
  end
end
