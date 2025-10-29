# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category variable
  # @liquid_name snippet
  # @liquid_summary
  #   Creates a new inline snippet.
  # @liquid_description
  #   You can create inline snippets to make your Liquid code more modular.
  # @liquid_syntax
  #   {% snippet snippet_name %}
  #     value
  #   {% endsnippet %}
  class Snippet < Block
    def initialize(tag_name, markup, options)
      super
      p = @parse_context.new_parser(markup)
      if p.look(:id)
        @to = p.consume(:id)
        p.consume(:end_of_string)
      else
        raise SyntaxError, options[:locale].t("errors.syntax.snippet")
      end
    end

    def render_to_output_buffer(context, output)
      snippet_drop = SnippetDrop.new(@body, @to, context.template_name)
      context.scopes.last[@to] = snippet_drop
      context.resource_limits.increment_assign_score(assign_score_of(snippet_drop))
      output
    end

    def blank?
      true
    end

    private

    def assign_score_of(snippet_drop)
      snippet_drop.body.nodelist.sum { |node| node.to_s.bytesize }
    end
  end
end
