# frozen_string_literal: true

module Liquid
  class InlineComment < Tag
    def render_to_output_buffer(_context, output)
      output
    end

    def blank?
      true
    end
  end

  Template.register_tag('#', InlineComment)
end
