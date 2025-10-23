# frozen_string_literal: true

module Liquid
  # @liquid_type tag
  # @liquid_category variable
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
    def initialize(tag_name, markup, options)
      super
      p = @parse_context.new_parser(markup)
      if p.look(:id)
        @to = p.consume(:id)
      else
        raise SyntaxError, options[:locale].t("errors.syntax.snippet")
      end
    end

    def render_to_output_buffer(context, output)
      snippet_drop = SnippetDrop.new(@body, @to)
      context.scopes.last[@to] = snippet_drop

      snippet_size = @body.nodelist.sum { |node| node.to_s.bytesize }
      context.resource_limits.increment_assign_score(snippet_size)

      output
    end

    def blank?
      true
    end
  end
end
