# frozen_string_literal: true

require "lru_redux"

module Liquid
  class Expression1
    LITERALS = {
      nil => nil,
      'nil' => nil,
      'null' => nil,
      '' => nil,
      'true' => true,
      'false' => false,
      'blank' => '',
      'empty' => ''
    }.freeze

    INTEGERS_REGEX       = /\A(-?\d+)\z/
    FLOATS_REGEX         = /\A(-?\d[\d\.]+)\z/

    # Use an atomic group (?>...) to avoid pathological backtracing from
    # malicious input as described in https://github.com/Shopify/liquid/issues/1357
    RANGES_REGEX         = /\A\(\s*(?>(\S+)\s*\.\.)\s*(\S+)\s*\)\z/

    def self.parse(markup, _ss = nil, _cache = nil)
      return nil unless markup

      markup = markup.strip
      if (markup.start_with?('"') && markup.end_with?('"')) ||
         (markup.start_with?("'") && markup.end_with?("'"))
        return markup[1..-2]
      end

      case markup
      when INTEGERS_REGEX
        Regexp.last_match(1).to_i
      when RANGES_REGEX
        RangeLookup.parse(Regexp.last_match(1), Regexp.last_match(2), nil)
      when FLOATS_REGEX
        Regexp.last_match(1).to_f
      else
        if LITERALS.key?(markup)
          LITERALS[markup]
        else
          VariableLookup.parse(markup, nil)
        end
      end
    end
  end

  class Expression2
    LITERALS = {
      nil => nil,
      'nil' => nil,
      'null' => nil,
      '' => nil,
      'true' => true,
      'false' => false,
      'blank' => '',
      'empty' => '',
      '-' => VariableLookup.parse("-", nil),
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

          cache[markup] = inner_parse(markup, ss, cache)
        else
          inner_parse(markup, ss, nil)
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
          return markup.to_i
        when FLOAT_REGEX
          return markup.to_f
        end

        ss.string = markup
        # the first byte must be a digit, a period, or  a dash
        byte = ss.scan_byte

        return false if byte != DASH && byte != DOT && (byte < ZERO || byte > NINE)

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

  Expression = StringScanner.instance_methods.include?(:scan_byte) ? Expression2 : Expression1
end
