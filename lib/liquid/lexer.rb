require "strscan"
module Liquid
  class Lexer
    SPECIALS = {
      '|' => :pipe,
      '.' => :dot,
      ':' => :colon,
      ',' => :comma,
      '[' => :open_square,
      ']' => :close_square,
      '(' => :open_round,
      ')' => :close_round
    }
    IDENTIFIER = /[\w\-?!]+/
    SINGLE_STRING_LITERAL = /'[^\']*'/
    DOUBLE_STRING_LITERAL = /"[^\"]*"/
    NUMBER_LITERAL = /-?\d+(\.\d+)?/
    COMPARISON_OPERATOR = /==|!=|<>|<=?|>=?|contains/

    def initialize(input)
      @ss = StringScanner.new(input)
    end

    def tokenize
      @output = []

      loop do
        @ss.skip(/\s*/)

        tok = case
        when @ss.eos? then nil
        when t = @ss.scan(COMPARISON_OPERATOR) then [:comparison, t]
        when t = @ss.scan(SINGLE_STRING_LITERAL) then [:string, t]
        when t = @ss.scan(DOUBLE_STRING_LITERAL) then [:string, t]
        when t = @ss.scan(NUMBER_LITERAL) then [:number, t]
        when t = @ss.scan(IDENTIFIER) then [:id, t]
        else
          c = @ss.getch
          if s = SPECIALS[c]
            [s,c]
          else
            raise SyntaxError, "Unexpected character #{c}"
          end
        end

        unless tok
          @output << [:end_of_string]
          return @output
        end
        @output << tok
      end
    end
  end
end
