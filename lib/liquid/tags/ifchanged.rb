module Liquid
  class Ifchanged < Block
            
    def render(context)
      context.stack do 
        
        output = render_all(@nodelist, context)

        if context.intermediate
          return "{%ifchanged%}#{output}{%endifchanged%}"
        end

        if output != context.registers[:ifchanged]
          context.registers[:ifchanged] = output
          output
        else
          ''
        end              
      end
    end
  end  
  
  Template.register_tag('ifchanged', Ifchanged)  
end
