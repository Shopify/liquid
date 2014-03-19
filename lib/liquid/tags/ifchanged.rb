module Liquid
  class Ifchanged < Block

    def render(render_output, context)
      context.stack do

        block_output = ""
        super(block_output, context)

        if block_output != context.registers[:ifchanged]
          context.registers[:ifchanged] = block_output
          render_output << block_output
        end
      end
    end
  end

  Template.register_tag('ifchanged', Ifchanged)
end
