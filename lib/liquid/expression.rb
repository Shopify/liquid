# frozen_string_literal: true

module Liquid
  class Expression
    class MethodLiteral
      attr_reader :to_liquid

      def initialize(method_name, to_liquid)
        @method_name = method_name
        @to_liquid = to_liquid
      end

      def to_s
        to_liquid.to_s
      end

      def test(other)
        other.respond_to?(@method_name) && other.send(@method_name) || self == other
      end
    end

    class EmptyLiteral < MethodLiteral
      include Enumerable

      def each; end

      def to_ary
        to_liquid
      end
    end

    LITERALS = {
      nil => nil, 'nil' => nil, 'null' => nil, '' => nil,
      'true' => true,
      'false' => false,
      'blank' => MethodLiteral.new(:blank?, '').freeze,
      'empty' => EmptyLiteral.new(:empty?, [].freeze).freeze
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
