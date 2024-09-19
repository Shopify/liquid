# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category theme
  # @liquid_name snippet
  # @liquid_summary
  #   Creates a new variable with a string value.
  # @liquid_description
  #   You can create complex strings with Liquid logic and variables.
  # @liquid_syntax
  #   {% snippet "input" %}
  #     value
  #   {% endsnippet %}
  # @liquid_syntax_keyword variable The name of the variable being created.
  # @liquid_syntax_keyword value The value you want to assign to the variable.
  class Snippet < Block
    SYNTAX = /(#{QuotedString}+)/o

    def initialize(tag_name, markup, options)
      super
      if markup =~ SYNTAX
        @to = Regexp.last_match(1)
      else
        raise SyntaxError, options[:locale].t("errors.syntax.snippet")
      end
    end

    def render(context)
      context.registers[:inline_snippet] ||= {}
      context.registers[@to] = @body
      ''
    end
  end
end
