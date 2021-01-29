# frozen_string_literal: true

module Liquid
  class InlineComment < Tag
    def blank?
      true
    end

    def render_to_output_buffer(_context, _output)
    end
  end

  Template.register_tag('--', InlineComment)
end

