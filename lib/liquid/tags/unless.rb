# frozen_string_literal: true

require_relative 'if'

# @public_docs
module Liquid
  # @public_docs
  # @title Unless
  # @syntax The syntax
  # @summary The opposite of `if`` – executes a block of code only if a certain condition is not met.
  # @type tag
  # @description
  #   Unless is a conditional just like 'if' but works on the inverse logic.
  #
  #     {% unless x < 0 %} x is greater than zero {% endunless %}
  class Unless < If
    def render_to_output_buffer(context, output)
      # First condition is interpreted backwards ( if not )
      first_block = @blocks.first
      result = Liquid::Utils.to_liquid_value(
        first_block.evaluate(context)
      )

      unless result
        return first_block.attachment.render_to_output_buffer(context, output)
      end

      # After the first condition unless works just like if
      @blocks[1..-1].each do |block|
        result = Liquid::Utils.to_liquid_value(
          block.evaluate(context)
        )

        if result
          return block.attachment.render_to_output_buffer(context, output)
        end
      end

      output
    end
  end

  Template.register_tag('unless', Unless)
end
