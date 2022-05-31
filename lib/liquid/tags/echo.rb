# frozen_string_literal: true

module Liquid
  # Echo outputs an expression
  #
  #   {% echo monkey %}
  #   {% echo user.name %}
  #
  # This is identical to variable output syntax, like {{ foo }}, but works
  # inside {% liquid %} tags. The full syntax is supported, including filters:
  #
  #   {% echo user | link %}
  #
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
