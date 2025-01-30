# frozen_string_literal: true

module Liquid
  class Lexer
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

    SINGLE_COMPARISON_TOKENS = [].tap do |table|
      table["<".ord] = COMPARISON_LESS_THAN
      table[">".ord] = COMPARISON_GREATER_THAN
      table.freeze
    end

    TWO_CHARS_COMPARISON_JUMP_TABLE = [].tap do |table|
      table["=".ord] = [].tap do |sub_table|
        sub_table["=".ord] = COMPARISON_EQUAL
        sub_table.freeze
      end
      table["!".ord] = [].tap do |sub_table|
        sub_table["=".ord] = COMPARISION_NOT_EQUAL
        sub_table.freeze
      end
      table.freeze
    end

    COMPARISON_JUMP_TABLE = [].tap do |table|
      table["<".ord] = [].tap do |sub_table|
        sub_table["=".ord] = COMPARISON_LESS_THAN_OR_EQUAL
        sub_table[">".ord] = COMPARISON_NOT_EQUAL_ALT
        sub_table.freeze
      end
      table[">".ord] = [].tap do |sub_table|
        sub_table["=".ord] = COMPARISON_GREATER_THAN_OR_EQUAL
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

    # rubocop:disable Metrics/BlockNesting
    class << self
      def tokenize(ss)
        output = []

        until ss.eos?
          ss.skip(WHITESPACE_OR_NOTHING)

          break if ss.eos?

          start_pos = ss.pos
          peeked = ss.peek_byte

          if (special = SPECIAL_TABLE[peeked])
            ss.scan_byte
            # Special case for ".."
            if special == DOT && ss.peek_byte == DOT_ORD
              ss.scan_byte
              output << DOTDOT
            elsif special == DASH
              # Special case for negative numbers
              if (peeked_byte = ss.peek_byte) && NUMBER_TABLE[peeked_byte]
                ss.pos -= 1
                output << [:number, ss.scan(NUMBER_LITERAL)]
              else
                output << special
              end
            else
              output << special
            end
          elsif (sub_table = TWO_CHARS_COMPARISON_JUMP_TABLE[peeked])
            ss.scan_byte
            if (peeked_byte = ss.peek_byte) && (found = sub_table[peeked_byte])
              output << found
              ss.scan_byte
            else
              raise_syntax_error(start_pos, ss)
            end
          elsif (sub_table = COMPARISON_JUMP_TABLE[peeked])
            ss.scan_byte
            if (peeked_byte = ss.peek_byte) && (found = sub_table[peeked_byte])
              output << found
              ss.scan_byte
            else
              output << SINGLE_COMPARISON_TOKENS[peeked]
            end
          else
            type, pattern = NEXT_MATCHER_JUMP_TABLE[peeked]

            if type && (t = ss.scan(pattern))
              # Special case for "contains"
              output << if type == :id && t == "contains" && output.last&.first != :dot
                COMPARISON_CONTAINS
              else
                [type, t]
              end
            else
              raise_syntax_error(start_pos, ss)
            end
          end
        end
        # rubocop:enable Metrics/BlockNesting
        output << EOS
      rescue ::ArgumentError => e
        if e.message == "invalid byte sequence in #{ss.string.encoding}"
          raise SyntaxError, "Invalid byte sequence in #{ss.string.encoding}"
        else
          raise
        end
      end

      def raise_syntax_error(start_pos, ss)
        ss.pos = start_pos
        # the character could be a UTF-8 character, use getch to get all the bytes
        raise SyntaxError, "Unexpected character #{ss.getch}"
      end
    end
  end
end
