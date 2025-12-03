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
      'blank' => MethodLiteral.new(:blank?, '').freeze,
      'empty' => MethodLiteral.new(:empty?, '').freeze,
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
          start_markup = Regexp.last_match(1)
          end_markup = Regexp.last_match(2)
          start_obj = parse(start_markup, ss, cache)
          end_obj = parse(end_markup, ss, cache)
          return RangeLookup.create(
            start_obj,
            end_obj,
            start_markup,
            end_markup,
          )
        end

        if (num = parse_number(markup))
          num
        else
          VariableLookup.parse(markup, ss, cache)
        end
      end

      def parse_number(markup)
        # check if the markup is simple integer or float
        case markup
        when INTEGER_REGEX
          Integer(markup, 10)
        when FLOAT_REGEX
          markup.to_f
        else
          false
        end
      end
    end
  end
end
