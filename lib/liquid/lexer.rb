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
    DASH_ORD = "-".ord
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

    WHITESPACE_TABLE = [].tap do |table|
      RUBY_WHITESPACE.each { |c| table[c.ord] = true }
      table["\v".ord] = true
      table.freeze
    end

    IDENTIFIER_TABLE = [].tap do |table|
      "a".upto("z") do |c|
        table[c.ord] = true
        table[c.upcase.ord] = true
      end
      "0".upto("9") { |c| table[c.ord] = true }
      table["_".ord] = true
      table["-".ord] = true
      table.freeze
    end

    QUESTION_ORD = "?".ord
    SINGLE_QUOTE = "'"
    DOUBLE_QUOTE = '"'
    SINGLE_QUOTE_ORD = SINGLE_QUOTE.ord

    # rubocop:disable Metrics/BlockNesting
    class << self
      # `input` is a String, or a scanner that responds to `string` and `pos`
      # (such as a StringScanner), for callers written for the StringScanner-based lexer.
      def tokenize(input)
        if input.is_a?(String)
          source = input
          pos = 0
        elsif input.respond_to?(:string) && input.respond_to?(:pos)
          scanner = input
          source = input.string
          pos = input.pos
        else
          source = String.try_convert(input)
          raise ::TypeError, "no implicit conversion of #{input.nil? ? "nil" : input.class} into String" unless source

          pos = 0
        end

        output = []
        eos = source.bytesize

        if pos < eos
          check_encoding(source)
        end

        while pos < eos
          byte = source.getbyte(pos)
          while byte && WHITESPACE_TABLE[byte]
            pos += 1
            byte = source.getbyte(pos)
          end

          break unless byte

          start_pos = pos

          if (special = SPECIAL_TABLE[byte])
            pos += 1
            # Special case for ".."
            if special == DOT && source.getbyte(pos) == DOT_ORD
              pos += 1
              output << DOTDOT
            elsif special == DASH
              # Special case for negative numbers
              if (peeked_byte = source.getbyte(pos)) && NUMBER_TABLE[peeked_byte]
                pos = scan_number(source, start_pos)
                output << [:number, source.byteslice(start_pos, pos - start_pos)]
              else
                output << special
              end
            else
              output << special
            end
          elsif (sub_table = TWO_CHARS_COMPARISON_JUMP_TABLE[byte])
            pos += 1
            if (peeked_byte = source.getbyte(pos)) && (found = sub_table[peeked_byte])
              output << found
              pos += 1
            else
              raise_syntax_error(start_pos, scanner || source)
            end
          elsif (sub_table = COMPARISON_JUMP_TABLE[byte])
            pos += 1
            if (peeked_byte = source.getbyte(pos)) && (found = sub_table[peeked_byte])
              output << found
              pos += 1
            else
              output << SINGLE_COMPARISON_TOKENS[byte]
            end
          else
            type, = NEXT_MATCHER_JUMP_TABLE[byte]

            case type
            when :id
              pos = scan_identifier(source, pos)
              t = source.byteslice(start_pos, pos - start_pos)
              # Special case for "contains"
              output << if t == "contains" && output.last&.first != :dot
                COMPARISON_CONTAINS
              else
                [:id, t]
              end
            when :number
              pos = scan_number(source, pos)
              output << [:number, source.byteslice(start_pos, pos - start_pos)]
            when :string
              close = source.byteindex(byte == SINGLE_QUOTE_ORD ? SINGLE_QUOTE : DOUBLE_QUOTE, pos + 1)
              raise_syntax_error(start_pos, scanner || source) unless close
              pos = close + 1
              output << [:string, source.byteslice(start_pos, pos - start_pos)]
            else
              raise_syntax_error(start_pos, scanner || source)
            end
          end
        end
        # rubocop:enable Metrics/BlockNesting
        # A scanner ends past the input, as it did when the lexer scanned it.
        scanner.pos = eos if scanner
        output << EOS
      end

      # `input` is a String, or a scanner for callers written for the StringScanner-based lexer.
      def raise_syntax_error(start_pos, input)
        if input.is_a?(String)
          # the character could be a UTF-8 character, so take up to four bytes and keep the first character
          char = input.byteslice(start_pos, 4)&.[](0) || +""
          # `char` is a new String, so prepending to it allocates no other String.
          raise SyntaxError, char.prepend("Unexpected character ")
        end

        input.pos = start_pos
        # the character could be a UTF-8 character, use getch to get all the bytes
        raise SyntaxError, "Unexpected character #{input.getch}"
      end

      private

      # The StringScanner-based lexer raised these errors from its first regular
      # expression match. Raise them at the same point.
      def check_encoding(source)
        # A match raises Encoding::CompatibilityError for an ASCII-incompatible source.
        WHITESPACE_OR_NOTHING.match?(source) unless source.encoding.ascii_compatible?

        raise SyntaxError, "Invalid byte sequence in #{source.encoding}" unless source.valid_encoding?
      end

      # Matches IDENTIFIER (/[a-zA-Z_][\w-]*\??/) from its first byte.
      def scan_identifier(source, pos)
        byte = source.getbyte(pos)
        while byte && IDENTIFIER_TABLE[byte]
          pos += 1
          byte = source.getbyte(pos)
        end
        pos += 1 if byte == QUESTION_ORD
        pos
      end

      # Matches NUMBER_LITERAL (/-?\d+(\.\d+)?/) from a dash or a digit.
      def scan_number(source, pos)
        pos += 1 if source.getbyte(pos) == DASH_ORD
        pos += 1 while (byte = source.getbyte(pos)) && NUMBER_TABLE[byte]

        if byte == DOT_ORD && (byte = source.getbyte(pos + 1)) && NUMBER_TABLE[byte]
          pos += 2
          pos += 1 while (byte = source.getbyte(pos)) && NUMBER_TABLE[byte]
        end

        pos
      end
    end
  end
end
