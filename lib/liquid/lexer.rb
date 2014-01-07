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
      ')'.freeze => :close_round
    }
    IDENTIFIER = /[\w\-?!]+/
    SINGLE_STRING_LITERAL = /'[^\']*'/
    DOUBLE_STRING_LITERAL = /"[^\"]*"/
    NUMBER_LITERAL = /-?\d+(\.\d+)?/
    DOTDOT = /\.\./
    COMPARISON_OPERATOR = /==|!=|<>|<=?|>=?|contains/

    def initialize(input)
      @ss = StringScanner.new(input.rstrip)
    end

    def tokenize
      @output = []

      while !@ss.eos?
        @ss.skip(/\s*/)
        tok = case
        when t = @ss.scan(COMPARISON_OPERATOR) then [:comparison, t]
        when t = @ss.scan(SINGLE_STRING_LITERAL) then [:string, t]
        when t = @ss.scan(DOUBLE_STRING_LITERAL) then [:string, t]
        when t = @ss.scan(NUMBER_LITERAL) then [:number, t]
        when t = @ss.scan(IDENTIFIER) then [:id, t]
        when t = @ss.scan(DOTDOT) then [:dotdot, t]
        else
          c = @ss.getch
          if s = SPECIALS[c]
            [s,c]
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
