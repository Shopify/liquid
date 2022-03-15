# frozen_string_literal: true

require_relative 'if'

# @public_docs
module Liquid
  # @public_docs
  # @title unless
  # @type tag
  # @category controlflow
  # @summary Executes a block of code only if a certain condition is not met (if the result is `falsy`).
  # @syntax
  #   {% unless variable operator value %}
  #     statement
  #   {% endunless %}
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
