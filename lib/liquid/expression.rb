module Liquid
  class Expression
    LITERALS = {
      nil => nil, 'nil'.freeze => nil, 'null'.freeze => nil, ''.freeze => nil,
      'true'.freeze  => true,
      'false'.freeze => false,
      'blank'.freeze => :blank?,
      'empty'.freeze => :empty?
    }

    INVERTED_LITERALS = LITERALS.invert

    def self.parse(markup)
      if LITERALS.key?(markup)
        LITERALS[markup]
      else
        case markup
        when /\A'(.*)'\z/m # Single quoted strings
          $1
        when /\A"(.*)"\z/m # Double quoted strings
          $1
        when /\A(-?\d+)\z/ # Integer and floats
          $1.to_i
        when /\A\((\S+)\.\.(\S+)\)\z/ # Ranges
          RangeLookup.parse($1, $2)
        when /\A(-?\d[\d\.]+)\z/ # Floats
          $1.to_f
        else
          VariableLookup.parse(markup)
        end
      end
    end

    def self.format(value)
      if INVERTED_LITERALS.key?(value)
        INVERTED_LITERALS[value].dup
      elsif value.is_a?(VariableLookup) || value.is_a?(RangeLookup)
        value.format
      elsif value.is_a?(String)
        "\"#{value}\""
      elsif value.is_a?(Range)
        "(#{value.to_s})"
      else
        value.to_s
      end
    end
  end
end
