# frozen_string_literal: true

module Liquid
  class HybridTag < Block
    def parse(tokens)
      if tokens.matching_end_tag?(tag_name)
        @block_form = true
        super
      else
        @block_form = false
      end
    end

    def block_form?
      @block_form
    end

    def nodelist
      @body ? @body.nodelist : Const::EMPTY_ARRAY
    end

    def render_to_output_buffer(context, output)
      if @block_form
        render_block_form_to_output_buffer(context, output)
      else
        render_self_closing_to_output_buffer(context, output)
      end
    end

    private

    def render_block_form_to_output_buffer(_context, _output)
      raise NotImplementedError, "#{self.class} must implement render_block_form_to_output_buffer"
    end

    def render_self_closing_to_output_buffer(_context, _output)
      raise NotImplementedError, "#{self.class} must implement render_self_closing_to_output_buffer"
    end
  end
end
