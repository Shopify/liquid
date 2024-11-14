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

    def self.parse(markup)
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
        RangeLookup.parse(Regexp.last_match(1), Regexp.last_match(2))
      when FLOATS_REGEX
        Regexp.last_match(1).to_f
      else
        if LITERALS.key?(markup)
          LITERALS[markup]
        else
          VariableLookup.parse(markup)
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
      'empty' => ''
    }.freeze

    DOT = ".".ord
    ZERO = "0".ord
    NINE = "9".ord
    DASH = "-".ord

    # Use an atomic group (?>...) to avoid pathological backtracing from
    # malicious input as described in https://github.com/Shopify/liquid/issues/1357
    RANGES_REGEX = /\A\(\s*(?>(\S+)\s*\.\.)\s*(\S+)\s*\)\z/
    CACHE = LruRedux::Cache.new(10_000) # most themes would have less than 2,000 unique expression

    class << self
      def string_scanner
        @ss ||= StringScanner.new("")
      end

      def parse(markup)
        return unless markup

        markup = markup.strip # markup can be a frozen string

        return CACHE[markup] if CACHE.key?(markup)

        CACHE[markup] = inner_parse(markup)
      end

      def inner_parse(markup)
        if (markup.start_with?('"') && markup.end_with?('"')) ||
          (markup.start_with?("'") && markup.end_with?("'"))
          return markup[1..-2]
        elsif (markup.start_with?("(") && markup.end_with?(")")) && markup =~ RANGES_REGEX
          return RangeLookup.parse(Regexp.last_match(1), Regexp.last_match(2))
        end

        return LITERALS[markup] if LITERALS.key?(markup)

        if (num = parse_number(markup))
          num
        else
          VariableLookup.parse(markup)
        end
      end

      def parse_number(markup)
        ss = string_scanner
        ss.string = markup

        is_integer = true
        last_dot_pos = nil
        num_end_pos = nil

        # the first byte must be a digit, a period, or  a dash
        byte = ss.scan_byte

        return false if byte != DASH && byte != DOT && (byte < ZERO || byte > NINE)

        while (byte = ss.scan_byte)
          return false if byte != DOT && (byte < ZERO || byte > NINE)

          # we found our number and now we are just scanning the rest of the string
          next if num_end_pos

          if byte == DOT
            if is_integer == false
              num_end_pos = ss.pos - 1
            else
              is_integer = false
              last_dot_pos = ss.pos
            end
          end
        end

        num_end_pos = markup.length if ss.eos?

        return markup.to_i if is_integer

        if num_end_pos
          # number ends with a number "123.123"
          markup.byteslice(0, num_end_pos).to_f
        elsif last_dot_pos
          markup.byteslice(0, last_dot_pos).to_f
        else
          # we should never reach this point
          false
        end
      end
    end
  end

  Expression = StringScanner.instance_methods.include?(:scan_byte) ? Expression2 : Expression1
end
