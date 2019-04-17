module Liquid
  class Ifchanged < Block
    def render(context, output)
      context.stack do
        block_output = super(context, '')

        if block_output != context.registers[:ifchanged]
          context.registers[:ifchanged] = block_output
          output << block_output
        end
      end

      output
    end
  end

  Template.register_tag('ifchanged'.freeze, Ifchanged)
end
