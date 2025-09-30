# frozen_string_literal: true

module Liquid
  # @liquid_type tag
  # @liquid_category theme
  # @liquid_name snippet
  # @liquid_summary
  #   Creates a new inline snippet.
  # @liquid_description
  #   You can create inline snippets to make your Liquid code more modular.
  # @liquid_syntax
  #   {% snippet input %}
  #     value
  #   {% endsnippet %}

  class Snippet < Block
    SYNTAX = /(#{VariableSignature}+)/o

    def initialize(tag_name, markup, options)
      super
      if markup =~ SYNTAX
        @to = Regexp.last_match(1)
      else
        raise SyntaxError, options[:locale].t("errors.syntax.snippet")
      end
    end

    def render_to_output_buffer(context, output)
      snippet_drop = SnippetDrop.new(@body)
      context.scopes.last[@to] = snippet_drop
      output
    end

    def blank?
      true
    end
  end
end
