require "strscan"
module Liquid
  class Lexer
    SPECIALS = {
      '|'.freeze => :pipe,
      '.'.freeze => :dot,
      ':'.freeze => :colon,
      ','.freeze => :comma,
      '['.freeze => :open_square,
      ']'.freeze => :close_square,
      '('.freeze => :open_round,
      ')'.freeze => :close_round,
      '?'.freeze => :question,
      '-'.freeze => :dash,
      '!'.freeze => :not,
    }
    IDENTIFIER = /[a-zA-Z_][\w-]*\??/
    BOOLEAN_OR = /or(?=\s)|\|\|/i
    BOOLEAN_AND = /and(?=\s)|&&/i
    BOOLEAN_NOT = /not(?=\s)/i
    SINGLE_STRING_LITERAL = /'[^\']*'/
    DOUBLE_STRING_LITERAL = /"[^\"]*"/
    NUMBER_LITERAL = /-?\d+(\.\d+)?/
    DOTDOT = /\.\./
    COMPARISON_OPERATOR = /==|!=|<>|<=?|>=?|contains(?=\s)/

    def initialize(input)
      @ss = StringScanner.new(input)
    end

    def tokenize
      @output = []

      until @ss.eos?
        @ss.skip(/\s*/)
        break if @ss.eos?
        tok = case
        when t = @ss.scan(COMPARISON_OPERATOR) then [:comparison, t]
        when t = @ss.scan(SINGLE_STRING_LITERAL) then [:string, t]
        when t = @ss.scan(DOUBLE_STRING_LITERAL) then [:string, t]
        when t = @ss.scan(NUMBER_LITERAL) then [:number, t]
        when t = @ss.scan(BOOLEAN_OR) then [:or, t]
        when t = @ss.scan(BOOLEAN_AND) then [:and, t]
        when t = @ss.scan(BOOLEAN_NOT) then [:not, t]
        when t = @ss.scan(IDENTIFIER) then [:id, t]
        when t = @ss.scan(DOTDOT) then [:dotdot, t]
        else
          c = @ss.getch
          if s = SPECIALS[c]
            [s, c]
          else
            raise SyntaxError, "Unexpected character #{c}"
          end
        end
        @output << tok
      end

      @output << [:end_of_string]
    end
  end
end
