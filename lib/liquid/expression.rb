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

    def self.lax_migrate(markup)
      Utils.migrate_stripped(markup) do |markup|
        raise ArgumentError, "unexpected empty expression" if markup.empty?

        if (markup.start_with?('"') && markup.end_with?('"')) ||
           (markup.start_with?("'") && markup.end_with?("'"))
          markup
        else
          case markup
          when INTEGERS_REGEX
            markup
          when RANGES_REGEX
            match = Regexp.last_match
            new_start, new_end = RangeLookup.lax_migrate(match[1], match[2])
            Utils.match_captures_replace(match, 1 => new_start, 2 => new_end)
          when FLOATS_REGEX
            # lax parser allowed multiple periods, but the second period and following characters were ignored
            new_markup = markup.slice(/\A(-?\d+\.\d*)/)
            new_markup << "0" if new_markup.end_with?(".")
            new_markup
          else
            if LITERALS.key?(markup)
              markup
            else
              VariableLookup.lax_migrate(markup)
            end
          end
        end
      end
    end
  end
end
