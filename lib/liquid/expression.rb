# frozen_string_literal: true

module Liquid
  class Expression
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

    class << self
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
        if (markup.start_with?("(") && markup.end_with?(")")) && markup =~ RANGES_REGEX
          return RangeLookup.parse(
            Regexp.last_match(1),
            Regexp.last_match(2),
            ss,
            cache,
          )
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
    end
  end
end
