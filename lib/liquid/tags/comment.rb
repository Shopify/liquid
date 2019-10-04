# frozen_string_literal: true

module Liquid
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
