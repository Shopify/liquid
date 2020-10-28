# frozen_string_literal: true

module Liquid
  class Expression
    LITERALS = {
      nil => nil, 'nil' => nil, 'null' => nil, '' => nil,
      'true' => true,
      'false' => false,
      'blank' => '',
      'empty' => ''
    }.freeze

    SINGLE_QUOTED_STRING = /\A\s*'(.*)'\s*\z/m
    DOUBLE_QUOTED_STRING = /\A\s*"(.*)"\s*\z/m
    INTEGERS_REGEX       = /\A\s*(-?\d+)\s*\z/
    FLOATS_REGEX         = /\A\s*(-?\d[\d\.]+)\s*\z/
    RANGES_REGEX         = /\A\s*\(\s*(\S+)\s*\.\.\s*(\S+)\s*\)\s*\z/

    def self.parse(markup)
      return markup unless markup.is_a?(String)

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
        markup = markup.strip
        LITERALS.key?(markup) ? LITERALS[markup] : VariableLookup.parse(markup)
      end
    end
  end
end
