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
      'empty' => ''
    }.freeze

    INTEGERS_REGEX       = /\A(-?\d+)\z/
    FLOATS_REGEX         = /\A(-?\d[\d\.]+)\z/

    # Use an atomic group (?>...) to avoid pathological backtracing from
    # malicious input as described in https://github.com/Shopify/liquid/issues/1357
    RANGES_REGEX         = /\A\(\s*(?>(\S+)\s*\.\.)\s*(\S+)\s*\)\z/

    include ParserSwitching

    def self.parse(markup, parse_context)
      new(markup, parse_context)
    end

    private_class_method def self.new(markup, parse_context)
      obj = allocate
      obj.instance_variable_set(:@markup, markup)
      obj.instance_variable_set(:@parse_context, parse_context)
      if !parse_context.nil?
        obj.strict_parse_with_error_mode_fallback(markup)
      else
        obj.lax_parse(markup)
      end
    end

    def strict_parse(markup)
      return nil unless markup

      p = Parser.new(markup)
      p.expression
    end

    def lax_parse(markup)
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
        RangeLookup.parse(Regexp.last_match(1), Regexp.last_match(2), parse_context)
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
end
