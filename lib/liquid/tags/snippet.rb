# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category theme
  # @liquid_name snippet
  # @liquid_summary
  #   Creates a new inline snippet using a string value as the identifier.
  # @liquid_description
  #   You can create inline snippets to make your Liquid code more modular.
  # @liquid_syntax
  #   {% snippet "input" %}
  #     value
  #   {% endsnippet %}
  class Snippet < Block
    SYNTAX = /(#{QuotedString})(?:\s*\|\s*([\w\s,]+)\s*\|)?/o
    def initialize(tag_name, markup, options)
      super

      if markup =~ SYNTAX
        @to = Regexp.last_match(1)
        args = Regexp.last_match(2)

        @args = args ? args.split(/\s*,\s*/) : []
      else
        raise SyntaxError, options[:locale].t("errors.syntax.snippet")
      end
    end

    def render(context)
      context.registers[:inline_snippet] ||= {}
      context.registers[:inline_snippet][snippet_id] = {
        body: snippet_body,
        args: @args,
      }
      ''
    end

    private

    def snippet_id
      @to[1, @to.size - 2]
    end

    def snippet_body
      body = @body
      body
    end
  end
end
