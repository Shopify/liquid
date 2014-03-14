module Liquid
  class Ifchanged < Block

    def render(context, render_output)
      context.stack do

        block_output = ""
        super(context, block_output)

        if block_output != context.registers[:ifchanged]
          context.registers[:ifchanged] = block_output
          render_output << block_output
        end
      end
    end
  end

  Template.register_tag('ifchanged', Ifchanged)
end
