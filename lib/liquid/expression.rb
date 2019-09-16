module Liquid
  class Expression
    class MethodLiteral
      attr_reader :method_name, :to_s

      def initialize(method_name, to_s)
        @method_name = method_name
        @to_s = to_s
      end

      def to_liquid
        to_s
      end
    end

    LITERALS = {
      nil => nil, 'nil'.freeze => nil, 'null'.freeze => nil, ''.freeze => nil,
      'true'.freeze => true,
      'false'.freeze => false,
      'blank'.freeze => MethodLiteral.new(:blank?, '').freeze,
      'empty'.freeze => MethodLiteral.new(:empty?, '').freeze
    }.freeze

    SINGLE_QUOTED_STRING = /\A'(.*)'\z/m
    DOUBLE_QUOTED_STRING = /\A"(.*)"\z/m
    INTEGERS_REGEX       = /\A(-?\d+)\z/
    FLOATS_REGEX         = /\A(-?\d[\d\.]+)\z/
    RANGES_REGEX         = /\A\((\S+)\.\.(\S+)\)\z/

    def self.parse(markup)
      if LITERALS.key?(markup)
        LITERALS[markup]
      else
        case markup
        when SINGLE_QUOTED_STRING, DOUBLE_QUOTED_STRING
          Regexp.last_match(1)
        when INTEGERS_REGEX
          Regexp.last_match(1).to_i
        when RANGES_REGEX
          RangeLookup.parse(Regexp.last_match(1), Regexp.last_match(2))
        when FLOATS_REGEX
          Regexp.last_match(1).to_f
        else
          VariableLookup.parse(markup)
        end
      end
    end
  end
end
