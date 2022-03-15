# frozen_string_literal: true
module Liquid
  # @public_docs
  # @type tag
  # @category theme
  # @title comment
  # @summary
  #   Allows you to comment out parts of a Liquid file.
  #   Any text within the opening and closing `comment` blocks won't be output,
  #   and any Liquid code won't be executed.
  # @syntax
  #   {% comment %}
  #     statement
  #   {% endcomment %}
  class Comment < Block
    def render_to_output_buffer(_context, output)
      output
    end

    def unknown_tag(_tag, _markup, _tokens)
    end

    def blank?
      true
    end
  end

  Template.register_tag('comment', Comment)
end
