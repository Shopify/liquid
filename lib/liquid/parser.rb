module Liquid
  # This class is used by tags to parse themselves
  # it provides helpers and encapsulates state
  class Parser
    def initialize(input)
      l = Lexer.new(input)
      @tokens = l.tokenize
      @p = 0 # pointer to current location
    end

    def consume(type = nil)
      token = @tokens[@p]
      if type && token.type != type
        raise SyntaxError, "Expected #{type} but found #{@tokens[@p]}"
      end
      @p += 1
      token.contents
    end

    def cur_token()
      tok = @tokens[@p]
      raise SyntaxError, 'Expected more input.' unless tok
      tok
    end

    def look(type)
      tok = @tokens[@p]
      return false unless tok
      tok.type == type
    end

    # === General Liquid parsing functions ===

    def expression
      token = cur_token
      if token.type == :id
        variable_signature
      elsif [:string, :integer, :float].include? token.type
        token.contents
      else
        raise SyntaxError, "#{token} is not a valid expression."
      end
    end

    def variable_signature
      str = consume(:id)
      if look(:dot)
        str << consume
        str << variable_signature
      elsif look(:open_square)
        str << consume
        str << expression
        str << consume(:close_square)
      end
      str
    end
  end
end
