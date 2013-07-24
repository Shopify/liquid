module Liquid
  # This class is used by tags to parse themselves
  # it provides helpers and encapsulates state
  class Parser
    def initialize(input)
      l = Lexer.new(input)
      @tokens = l.tokenize
      @p = 0 # pointer to current location
    end

    def consume(type)
      token = @tokens[@p]
      if match && token.type != type
        raise SyntaxError, "Expected #{match} but found #{@tokens[@p]}"
      end
      @p += 1
      token
    end

    def look(type)
      @tokens[@p].type == type
    end

    # === General Liquid parsing functions ===
  end
end
