require_relative 'if'

module Liquid
  # Unless is a conditional just like 'if' but works on the inverse logic.
  #
  #   {% unless x < 0 %} x is greater than zero {% endunless %}
  #
  class Unless < If
    def render_to_output_buffer(context, output)
      context.stack do
        # First condition is interpreted backwards ( if not )
        first_block = @blocks.first
        unless first_block.evaluate(context)
          return first_block.attachment.render_to_output_buffer(context, output)
        end

        # After the first condition unless works just like if
        @blocks[1..-1].each do |block|
          if block.evaluate(context)
            return block.attachment.render_to_output_buffer(context, output)
          end
        end
      end

      output
    end

    def format(left, right)
      format_blocks(left, right, "unless")
    end
  end

  Template.register_tag('unless'.freeze, Unless)
end
