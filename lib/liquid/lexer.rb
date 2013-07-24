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
      @input = input.chars.to_a
    end

    def tokenize
      @p = 0
      @output = []

      loop do
        consume_whitespace
        c = @input[@p]

        # are we out of input?
        return @output unless c

        if identifier?(c)
          @output << consume_identifier
        elsif s = SPECIALS[c]
          @output << Token[s]
          @p += 1
        end
      end
    end

    def identifier?(c)
      c =~ /^[\w\-]$/
    end

    def whitespace?(c)
      c =~ /^\s$/
    end

    def consume_whitespace
      while whitespace?(@input[@p])
        @p += 1
      end
    end

    def consume_identifier
      str = ""
      while identifier?(@input[@p])
        str << @input[@p]
        @p += 1
      end
      Token[:identifier, str]
    end
  end
end
