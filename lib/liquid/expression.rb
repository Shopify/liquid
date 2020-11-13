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
    RANGES_REGEX         = /\A\s*\(.*\)\s*\z/

    def self.parse(markup)
      case markup
      when nil
        nil
      when SINGLE_QUOTED_STRING, DOUBLE_QUOTED_STRING
        Regexp.last_match(1)
      when INTEGERS_REGEX
        Regexp.last_match(1).to_i
      when RANGES_REGEX
        parts = markup.strip.gsub(/\A\(|\)\Z/, '').split(/\.{2,}/)
        return RangeLookup.parse(parts[0].strip, parts[1].strip) if parts.count == 2
      when FLOATS_REGEX
        Regexp.last_match(1).to_f
      else
        markup = markup.strip
        if LITERALS.key?(markup)
          LITERALS[markup]
        else
          VariableLookup.parse(markup)
        end
      end
    end
  end
end
