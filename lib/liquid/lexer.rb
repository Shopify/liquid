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

    def to_s
      self.inspect
    end
  end

  class Lexer
    SPECIALS = {
      '|' => :pipe,
      '.' => :dot,
      ':' => :colon,
      ',' => :comma,
      '[' => :open_square,
      ']' => :close_square
    }

    MATCHERS = {
      /([\w\-]+)/ => :id,
      /('[^\']*')/ => :string,
      /("[^\"]*")/ => :string,
      /(-?\d+)/ => :integer,
      /(-?\d+(?:\.\d+)?)/ => :float
    }
    MATCHER_REGEX = Regexp.union(MATCHERS.keys)
    MATCHER_TOKENS = MATCHERS.values


    def initialize(input)
      @ss = StringScanner.new(input)
    end

    def tokenize
      @output = []

      loop do
        tok = next_token
        unless tok
          @output << Token[:end_of_string]
          return @output
        end
        @output << tok
      end
    end

    def next_token
      consume_whitespace
      return if @ss.eos?

      tok_contents = @ss.scan(MATCHER_REGEX)
      tok_type = nil
      MATCHER_TOKENS.each_with_index do |type, i|
        if @ss[i+1]
          tok_type = type
          break
        end
      end

      return Token[tok_type, tok_contents] if tok_type
      
      c = @ss.getch
      if s = SPECIALS[c]
        return Token[s,c]
      end

      raise SyntaxError, "Unexpected character #{c}."
    end

    def consume_whitespace
      @ss.skip(/\s*/)
    end
  end
end
