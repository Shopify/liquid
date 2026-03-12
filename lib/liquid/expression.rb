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
      def safe_parse(parser, ss = StringScanner.new(""), cache = nil)
        parse(parser.expression, ss, cache)
      end

      def parse(markup, ss = StringScanner.new(""), cache = nil)
        return unless markup

        # Only strip if there's leading/trailing whitespace (avoids allocation)
        first_byte = markup.getbyte(0)
        if first_byte == 32 || first_byte == 9 || first_byte == 10 || first_byte == 13 # space, tab, \n, \r
          markup = markup.strip
        else
          last_byte = markup.getbyte(markup.bytesize - 1)
          markup = markup.strip if last_byte == 32 || last_byte == 9 || last_byte == 10 || last_byte == 13
        end

        if (markup.start_with?('"') && markup.end_with?('"')) ||
          (markup.start_with?("'") && markup.end_with?("'"))
          return markup.byteslice(1, markup.bytesize - 2)
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
        if markup.start_with?("(") && markup.end_with?(")") && markup =~ RANGES_REGEX
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

      def parse_number(markup, _ss = nil)
        len = markup.bytesize
        return false if len == 0

        # Quick reject: first byte must be digit or dash
        pos = 0
        first = markup.getbyte(pos)
        if first == DASH
          pos += 1
          return false if pos >= len

          b = markup.getbyte(pos)
          return false if b < ZERO || b > NINE

          pos += 1
        elsif first >= ZERO && first <= NINE
          pos += 1
        else
          return false
        end

        # Scan digits
        while pos < len
          b = markup.getbyte(pos)
          break if b < ZERO || b > NINE

          pos += 1
        end

        # If we consumed everything, it's a simple integer
        if pos == len
          return Integer(markup, 10)
        end

        # Check for dot (float)
        if markup.getbyte(pos) == DOT
          dot_pos = pos
          pos += 1
          # Must have at least one digit after dot
          digit_after_dot = pos
          while pos < len
            b = markup.getbyte(pos)
            break if b < ZERO || b > NINE

            pos += 1
          end

          if pos > digit_after_dot && pos == len
            # Simple float like "123.456"
            return markup.to_f
          elsif pos > digit_after_dot
            # Float followed by more dots or other chars: "1.2.3.4"
            # Return the float portion up to second dot
            while pos < len
              b = markup.getbyte(pos)
              if b == DOT
                return markup.byteslice(0, pos).to_f
              elsif b < ZERO || b > NINE
                return false
              end

              pos += 1
            end
            return markup.byteslice(0, pos).to_f
          else
            # dot at end: "123."
            return markup.byteslice(0, dot_pos).to_f
          end
        end

        # Not a number (has non-digit, non-dot characters)
        false
      end
    end
  end
end
