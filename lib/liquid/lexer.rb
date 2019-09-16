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
    }.freeze
    IDENTIFIER = /[a-zA-Z_][\w-]*\??/
    SINGLE_STRING_LITERAL = /'[^\']*'/
    DOUBLE_STRING_LITERAL = /"[^\"]*"/
    NUMBER_LITERAL = /-?\d+(\.\d+)?/
    DOTDOT = /\.\./
    COMPARISON_OPERATOR = /==|!=|<>|<=?|>=?|contains(?=\s)/
    WHITESPACE_OR_NOTHING = /\s*/

    def initialize(input)
      @ss = StringScanner.new(input)
    end

    def tokenize
      @output = []

      until @ss.eos?
        @ss.skip(WHITESPACE_OR_NOTHING)
        break if @ss.eos?
        tok = if t = @ss.scan(COMPARISON_OPERATOR) then [:comparison, t]
        elsif t = @ss.scan(SINGLE_STRING_LITERAL) then [:string, t]
        elsif t = @ss.scan(DOUBLE_STRING_LITERAL) then [:string, t]
        elsif t = @ss.scan(NUMBER_LITERAL) then [:number, t]
        elsif t = @ss.scan(IDENTIFIER) then [:id, t]
        elsif t = @ss.scan(DOTDOT) then [:dotdot, t]
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
