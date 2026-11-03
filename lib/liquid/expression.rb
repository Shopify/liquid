# frozen_string_literal: true

module Liquid
  class Expression
    SELF = 'self'

    LITERALS = {
      nil => nil,
      'nil' => nil,
      'null' => nil,
      '' => nil,
      'true' => true,
      'false' => false,
      'blank' => '',
      'empty' => '',
      # in lax mode, minus sign can be a VariableLookup
      # For simplicity and performace, we treat it like a literal
      '-' => VariableLookup.parse("-", nil).freeze,
    }.freeze

    DOT = ".".ord
    ZERO = "0".ord
    NINE = "9".ord
    DASH = "-".ord

    # Use an atomic group (?>...) to avoid pathological backtracing from
    # malicious input as described in https://github.com/Shopify/liquid/issues/1357
    RANGES_REGEX = /\A\(\s*(?>(\S+)\s*\.\.)\s*(\S+)\s*\)\z/
    INTEGER_REGEX = /\A(-?\d+)\z/
    FLOAT_REGEX = /\A(-?\d+)\.\d+\z/
    RANGE_MARKUP_WITH_NESTED_LOOKUPS = /["'\[]/

    class << self
      def safe_parse(parser, ss = StringScanner.new(""), cache = nil)
        parse(parser.expression, ss, cache)
      end

      def parse(markup, ss = StringScanner.new(""), cache = nil)
        return unless markup

        markup = markup.strip # markup can be a frozen string

        if (markup.start_with?('"') && markup.end_with?('"')) ||
          (markup.start_with?("'") && markup.end_with?("'"))
          return markup[1..-2]
        elsif LITERALS.key?(markup)
          return LITERALS[markup]
        end

        # Cache only exists during parsing
        if cache
          return cache[markup] if cache.key?(markup)

          cache[markup] = inner_parse(markup, ss, cache).freeze
        else
          inner_parse(markup, ss, nil).freeze
        end
      end

      def inner_parse(markup, ss, cache)
        if markup.start_with?("(") && markup.end_with?(")") && (match = RANGES_REGEX.match(markup))
          start_markup = match[1]
          if start_markup.match?(RANGE_MARKUP_WITH_NESTED_LOOKUPS) && !range_markup_start_balanced?(start_markup)
            range_markups = parse_range_markup(markup)
            return RangeLookup.parse(range_markups[0], range_markups[1], ss, cache) if range_markups
          else
            return RangeLookup.parse(start_markup, match[2], ss, cache)
          end
        end

        if (num = parse_number(markup, ss))
          num
        else
          VariableLookup.parse(markup, ss, cache)
        end
      end

      def parse_number(markup, ss)
        # check if the markup is simple integer or float
        case markup
        when INTEGER_REGEX
          return Integer(markup, 10)
        when FLOAT_REGEX
          return markup.to_f
        end

        ss.string = markup
        # the first byte must be a digit or  a dash
        byte = ss.scan_byte

        return false if byte != DASH && (byte < ZERO || byte > NINE)

        if byte == DASH
          peek_byte = ss.peek_byte

          # if it starts with a dash, the next byte must be a digit
          return false if peek_byte.nil? || !(peek_byte >= ZERO && peek_byte <= NINE)
        end

        # The markup could be a float with multiple dots
        first_dot_pos = nil
        num_end_pos = nil

        while (byte = ss.scan_byte)
          return false if byte != DOT && (byte < ZERO || byte > NINE)

          # we found our number and now we are just scanning the rest of the string
          next if num_end_pos

          if byte == DOT
            if first_dot_pos.nil?
              first_dot_pos = ss.pos
            else
              # we found another dot, so we know that the number ends here
              num_end_pos = ss.pos - 1
            end
          end
        end

        num_end_pos = markup.length if ss.eos?

        if num_end_pos
          # number ends with a number "123.123"
          markup.byteslice(0, num_end_pos).to_f
        else
          # number ends with a dot "123."
          markup.byteslice(0, first_dot_pos).to_f
        end
      end

      # A separator inside a quoted lookup leaves the regex's left capture unbalanced.
      def range_markup_start_balanced?(markup)
        markup.count("[") == markup.count("]") && markup.count('"').even? && markup.count("'").even?
      end
      private :range_markup_start_balanced?

      def parse_range_markup(markup)
        quote = nil
        bracket_depth = 0
        delimiter_index = nil
        index = 1
        end_index = markup.bytesize - 1

        # Keep the regex's rightmost-separator behaviour for triple-dot ranges.
        while index < end_index
          byte = markup.getbyte(index)

          if quote
            if byte == "\\".ord
              index += 2
              next
            elsif byte == quote
              quote = nil
            end
          else
            case byte
            when 34, 39
              quote = byte
            when "[".ord
              bracket_depth += 1
            when "]".ord
              bracket_depth -= 1 if bracket_depth.positive?
            when DOT
              delimiter_index = index if bracket_depth.zero? && markup.getbyte(index + 1) == DOT
            end
          end

          index += 1
        end

        return unless delimiter_index

        start_markup = markup.byteslice(1...delimiter_index).strip
        end_markup = markup.byteslice((delimiter_index + 2)...-1).strip
        return if start_markup.empty? || end_markup.empty?

        [start_markup, end_markup]
      end
      private :parse_range_markup
    end
  end
end
