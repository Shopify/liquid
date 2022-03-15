# frozen_string_literal: true

module Liquid
  # @public_docs
  # @type tag
  # @category theme
  # @title echo
  # @summary
  #   Outputs an expression, or Liquid object, in the rendered HTML.
  #   Works the same as wrapping an expression in double curly brace delimiters `{{ }}`.
  #   Works inside the [`liquid`](/api/liquid/tags/theme-tags#liquid) tag and supports [filters](/api/liquid/filters).
  # @syntax
  #   {% echo 'string' %}
  class Echo < Tag
    attr_reader :variable

    def initialize(tag_name, markup, parse_context)
      super
      @variable = Variable.new(markup, parse_context)
    end

    def render(context)
      @variable.render_to_output_buffer(context, +'')
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.variable]
      end
    end
  end

  Template.register_tag('echo', Echo)
end
