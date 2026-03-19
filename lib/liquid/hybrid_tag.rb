# frozen_string_literal: true

module Liquid
  class HybridTag < Block
    def reparent_as_block(children, parse_context)
      @body = new_body
      @body.nodelist.concat(children)
      @body.freeze
    end

    def parse(_tokens)
    end

    def block_form?
      !!@body
    end

    def nodelist
      @body ? @body.nodelist : Const::EMPTY_ARRAY
    end

    def blank?
      raise NotImplementedError, "#{self.class} must implement blank?"
    end

    def render_to_output_buffer(context, output)
      if block_form?
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
