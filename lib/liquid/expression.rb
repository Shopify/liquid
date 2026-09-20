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

    # Use an atomic group (?>...) to avoid pathological backtracing from
    # malicious input as described in https://github.com/Shopify/liquid/issues/1357
    RANGES_REGEX = /\A\(\s*(?>(\S+)\s*\.\.)\s*(\S+)\s*\)\z/

    class << self
      def safe_parse(parser, ss = StringScanner.new(""), cache = nil)
        parse(parser.expression, ss, cache)
      end

      def parse(markup, ss = StringScanner.new(""), cache = nil)
        return unless markup

        # Guard: only call .strip when the first or last byte is whitespace.
        # String#strip always allocates a new String, even when there's nothing
        # to strip. ByteTables::WHITESPACE matches the same bytes that strip
        # removes (space, \t, \n, \v, \f, \r, \x00). When neither end has
        # whitespace, we skip the call and avoid ~4,464 allocations per compile.
        first = markup.getbyte(0)
        if first && (ByteTables::WHITESPACE[first] || ByteTables::WHITESPACE[markup.getbyte(markup.bytesize - 1)])
          markup = markup.strip
        end

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

      # Fast path for number parsing. Accepts:
      #   - Simple integers: "42", "-7"
      #   - Simple floats: "3.14", "-0.5"
      #   - Multi-dot floats (truncated at second dot): "1.2.3" → 1.2
      #   - Trailing-dot floats: "123." → 123.0
      # Rejects (returns nil → caller treats as VariableLookup):
      #   - Non-numeric input: "hello", ""
      #   - Inputs with non-digit/non-dot bytes after the number: "1.2.3a"
      # Fallback: nil return causes caller to fall through to VariableLookup.parse,
      #   which is the same path the old regex-based code took on non-match.
      def parse_number(markup, _ss = nil)
        len = markup.bytesize
        return if len == 0

        pos = 0
        first = markup.getbyte(pos)

        if first == ByteTables::DASH
          pos += 1
          return if pos >= len
          return unless ByteTables::DIGIT[markup.getbyte(pos)]

          pos += 1
        elsif ByteTables::DIGIT[first]
          pos += 1
        else
          return
        end

        # Scan digits
        pos += 1 while pos < len && ByteTables::DIGIT[markup.getbyte(pos)]

        # Consumed everything = simple integer
        return Integer(markup, 10) if pos == len

        # Check for dot — three float cases:
        #   1. Simple float:   "123.456"   → markup.to_f
        #   2. Multi-dot:      "1.2.3.4"   → truncate at second dot → 1.2
        #   3. Trailing dot:   "123."      → truncate before dot → 123.0
        return unless markup.getbyte(pos) == ByteTables::DOT

        dot_pos = pos
        pos += 1
        digit_start = pos
        pos += 1 while pos < len && ByteTables::DIGIT[markup.getbyte(pos)]

        if pos > digit_start && pos == len
          # Case 1: simple float like "123.456"
          markup.to_f
        elsif pos > digit_start
          # Case 2: multi-dot like "1.2.3.4" — find where the numeric
          # portion ends. Reject if any non-digit, non-dot byte is found
          # (e.g. "1.2.3a" → nil, matching the old regex-based behavior).
          num_end = nil
          check = pos
          while check < len
            b = markup.getbyte(check)
            if b == ByteTables::DOT
              num_end ||= check
            elsif !ByteTables::DIGIT[b]
              return
            end
            check += 1
          end
          markup.byteslice(0, num_end || len).to_f
        else
          # Case 3: trailing dot like "123."
          markup.byteslice(0, dot_pos).to_f
        end
      end
    end
  end
end
