module Liquid
  class Token
    attr_accessor :type, :contents
    def initialize(*args)
      @type, @contents = args
    end

    def self.[](*args)
      Token.new(*args)
    end

    def inspect
      out = "<#{@type}"
      out << ": \'#{@contents}\'" if contents
      out << '>'
    end
  end

  class Lexer
    SPECIALS = {
      '|' => :pipe,
      '.' => :dot,
      ':' => :colon,
      ',' => :comma
    }

    def initialize(input)
      @input = input
    end

    def tokenize
      @p = 0
      @output = []

      loop do
        tok = next_token
        return @output unless tok
        @output << tok
      end
    end

    def next_token
      consume_whitespace
      c = @input[@p]
      return nil unless c

      if identifier?(c)
        identifier
      elsif c == '"' || c == '\''
        string_literal
      elsif s = SPECIALS[c]
        @p += 1
        Token[s]
      else
        raise SyntaxError, "Unexpected character #{c}."
      end
    end

    def identifier?(c)
      c =~ /^[\w\-]$/
    end

    def whitespace?(c)
      c =~ /^\s$/
    end

    def consume
      c = @input[@p]
      @p += 1
      c
    end

    def consume_whitespace
      while whitespace?(@input[@p])
        @p += 1
      end
    end

    def identifier
      str = ""
      while identifier?(@input[@p])
        str << @input[@p]
        @p += 1
      end
      Token[:id, str]
    end

    def string_literal
      quote = consume()

      start = @p
      while @input[@p] != quote
        @p += 1
      end
      @p += 1 # closing quote

      Token[:string, @input[start..(@p-2)]]
    end

    def number_literal
  end
end
