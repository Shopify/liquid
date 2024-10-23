# frozen_string_literal: true

require "strscan"

module Liquid
  class Lexer1
    SPECIALS = {
      '|' => :pipe,
      '.' => :dot,
      ':' => :colon,
      ',' => :comma,
      '[' => :open_square,
      ']' => :close_square,
      '(' => :open_round,
      ')' => :close_round,
      '?' => :question,
      '-' => :dash,
    }.freeze
    IDENTIFIER            = /[a-zA-Z_][\w-]*\??/
    SINGLE_STRING_LITERAL = /'[^\']*'/
    DOUBLE_STRING_LITERAL = /"[^\"]*"/
    STRING_LITERAL        = Regexp.union(SINGLE_STRING_LITERAL, DOUBLE_STRING_LITERAL)
    NUMBER_LITERAL        = /-?\d+(\.\d+)?/
    DOTDOT                = /\.\./
    COMPARISON_OPERATOR   = /==|!=|<>|<=?|>=?|contains(?=\s)/
    WHITESPACE_OR_NOTHING = /\s*/

    def initialize(input)
      @ss = StringScanner.new(input)
    end

    def tokenize
      @output = []

      until @ss.eos?
        @ss.skip(WHITESPACE_OR_NOTHING)
        break if @ss.eos?
        tok      = if (t = @ss.scan(COMPARISON_OPERATOR))
          [:comparison, t]
        elsif (t = @ss.scan(STRING_LITERAL))
          [:string, t]
        elsif (t = @ss.scan(NUMBER_LITERAL))
          [:number, t]
        elsif (t = @ss.scan(IDENTIFIER))
          [:id, t]
        elsif (t = @ss.scan(DOTDOT))
          [:dotdot, t]
        else
          c     = @ss.getch
          if (s = SPECIALS[c])
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

  class Lexer2
    CLOSE_ROUND = [:close_round, ")"].freeze
    CLOSE_SQUARE = [:close_square, "]"].freeze
    COLON = [:colon, ":"].freeze
    COMMA = [:comma, ","].freeze
    COMPARISION_NOT_EQUAL = [:comparison, "!="].freeze
    COMPARISON_CONTAINS = [:comparison, "contains"].freeze
    COMPARISON_EQUAL = [:comparison, "=="].freeze
    COMPARISON_GREATER_THAN = [:comparison, ">"].freeze
    COMPARISON_GREATER_THAN_OR_EQUAL = [:comparison, ">="].freeze
    COMPARISON_LESS_THAN = [:comparison, "<"].freeze
    COMPARISON_LESS_THAN_OR_EQUAL = [:comparison, "<="].freeze
    COMPARISON_NOT_EQUAL_ALT = [:comparison, "<>"].freeze
    CONTAINS = /contains(?=\s)/
    DASH = [:dash, "-"].freeze
    DOT = [:dot, "."].freeze
    DOTDOT = [:dotdot, ".."].freeze
    DOT_ORD = ".".ord
    DOUBLE_STRING_LITERAL = /"[^\"]*"/
    EOS = [:end_of_string].freeze
    IDENTIFIER            = /[a-zA-Z_][\w-]*\??/
    NUMBER_LITERAL        = /-?\d+(\.\d+)?/
    OPEN_ROUND = [:open_round, "("].freeze
    OPEN_SQUARE = [:open_square, "["].freeze
    PIPE = [:pipe, "|"].freeze
    QUESTION = [:question, "?"].freeze
    RUBY_WHITESPACE = [" ", "\t", "\r", "\n", "\f"].freeze
    SINGLE_STRING_LITERAL = /'[^\']*'/
    WHITESPACE_OR_NOTHING = /\s*/

    COMPARISON_JUMP_TABLE = [].tap do |table|
      table["=".ord] = [].tap do |sub_table|
        sub_table["=".ord] = COMPARISON_EQUAL
        sub_table.freeze
      end
      table["!".ord] = [].tap do |sub_table|
        sub_table["=".ord] = COMPARISION_NOT_EQUAL
        sub_table.freeze
      end
      table["<".ord] = [].tap do |sub_table|
        sub_table["=".ord] = COMPARISON_LESS_THAN_OR_EQUAL
        sub_table[">".ord] = COMPARISON_NOT_EQUAL_ALT
        RUBY_WHITESPACE.each { |c| sub_table[c.ord] = COMPARISON_LESS_THAN }
        sub_table.freeze
      end
      table[">".ord] = [].tap do |sub_table|
        sub_table["=".ord] = COMPARISON_GREATER_THAN_OR_EQUAL
        RUBY_WHITESPACE.each { |c| sub_table[c.ord] = COMPARISON_GREATER_THAN }
        sub_table.freeze
      end
      table.freeze
    end

    NEXT_MATCHER_JUMP_TABLE = [].tap do |table|
      "a".upto("z") do |c|
        table[c.ord] = [:id, IDENTIFIER].freeze
        table[c.upcase.ord] = [:id, IDENTIFIER].freeze
      end
      table["_".ord] = [:id, IDENTIFIER].freeze

      "0".upto("9") do |c|
        table[c.ord] = [:number, NUMBER_LITERAL].freeze
      end
      table["-".ord] = [:number, NUMBER_LITERAL].freeze

      table["'".ord] = [:string, SINGLE_STRING_LITERAL].freeze
      table["\"".ord] = [:string, DOUBLE_STRING_LITERAL].freeze
      table.freeze
    end

    SPECIAL_TABLE = [].tap do |table|
      table["|".ord] = PIPE
      table[".".ord] = DOT
      table[":".ord] = COLON
      table[",".ord] = COMMA
      table["[".ord] = OPEN_SQUARE
      table["]".ord] = CLOSE_SQUARE
      table["(".ord] = OPEN_ROUND
      table[")".ord] = CLOSE_ROUND
      table["?".ord] = QUESTION
      table["-".ord] = DASH
    end

    NUMBER_TABLE = [].tap do |table|
      "0".upto("9") do |c|
        table[c.ord] = true
      end
      table.freeze
    end

    def initialize(input)
      @ss = StringScanner.new(input)
    end

    # rubocop:disable Metrics/BlockNesting
    def tokenize
      @output = []

      until @ss.eos?
        @ss.skip(WHITESPACE_OR_NOTHING)

        break if @ss.eos?

        peeked = @ss.peek_byte

        if (special = SPECIAL_TABLE[peeked])
          @ss.scan_byte
          # Special case for ".."
          if special == DOT && @ss.peek_byte == DOT_ORD
            @ss.scan_byte
            @output << DOTDOT
          elsif special == DASH
            # Special case for negative numbers
            if NUMBER_TABLE[@ss.peek_byte]
              @ss.pos -= 1
              @output << [:number, @ss.scan(NUMBER_LITERAL)]
            else
              @output << special
            end
          else
            @output << special
          end
        elsif (sub_table = COMPARISON_JUMP_TABLE[peeked])
          @ss.scan_byte
          if (found = sub_table[@ss.peek_byte])
            @output << found
            @ss.scan_byte
          else
            raise SyntaxError, "Unexpected character #{peeked.chr}"
          end
        else
          type, pattern = NEXT_MATCHER_JUMP_TABLE[peeked]

          if type && (t = @ss.scan(pattern))
            # Special case for "contains"
            @output << if type == :id && t == "contains"
              COMPARISON_CONTAINS
            else
              [type, t]
            end
          else
            raise SyntaxError, "Unexpected character #{peeked.chr}"
          end
        end
      end
      # rubocop:enable Metrics/BlockNesting

      @output << EOS
    end
  end

  Lexer = StringScanner.instance_methods.include?(:scan_byte) ? Lexer2 : Lexer1
end
