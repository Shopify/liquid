module Liquid
  class Ifchanged < Block
    def render(context)
      output = super

      if output != context.registers[:ifchanged]
        context.registers[:ifchanged] = output
        output
      else
        ''.freeze
      end
    end
  end

  Template.register_tag('ifchanged'.freeze, Ifchanged)
end
