module Liquid
  class Ifchanged < Block
    def render_to_output_buffer(context)
      context.stack do
        block_output = render(context)

        if block_output != context.registers[:ifchanged]
          context.registers[:ifchanged] = block_output
          context.output << block_output
        end
      end

      context.output
    end
  end

  Template.register_tag('ifchanged'.freeze, Ifchanged)
end
