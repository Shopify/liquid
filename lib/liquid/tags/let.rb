# frozen_string_literal: true

module Liquid
  class Let < Liquid::Block
    MULTI_ASSIGNMENT = /\A\(\s*(?<vars>[^)]+)\s*\):\s*(?<source>[^\s]+)\z/
    VAR_ASSIGNMENTS  = /(?<var>[\w-]+)\s*:\s*(?<expr>[^\s,]+)/

    def initialize(tag_name, markup, options)
      super(tag_name, markup, options)
      @assignments = parse_markup(markup.strip)
    end

    def render(context)
      subcontext = context.new_isolated_subcontext

      @assignments.each do |var, expression|
        subcontext[var] = lookup(context, expression)
      end

      super(subcontext)
    end

    private

    def parse_markup(markup)
      if (m = MULTI_ASSIGNMENT.match(markup))
        variables = m[:vars].split(/\s*,\s*/)
        source    = m[:source]
        variables.map { |v| [v, "#{source}.#{v}"] }.to_h
      else
        markup.scan(VAR_ASSIGNMENTS).to_h
      end
    end

    def lookup(context, expression)
      variable_lookup = Liquid::VariableLookup.new(expression)
      variable_lookup.evaluate(context)
    end
  end
end
