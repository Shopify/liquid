require File.dirname(__FILE__) + '/if'

module Liquid

  # Unless is a conditional just like 'if' but works on the inverse logic.
  #
  #   {% unless x < 0 %} x is greater than zero {% end %}
  #
  class Unless < If
    def render(context)
      context.stack do
        
        # First condition is interpreted backwards ( if not )
        block = @blocks.first
        unless block.evaluate(context)
          return render_all(block.attachment, context)            
        end
        
        # After the first condition unless works just like if
        @blocks[1..-1].each do |block|
          if block.evaluate(context)            
            return render_all(block.attachment, context)            
          end
        end 
        
        ''
      end
    end    
  end
  

  Template.register_tag('unless', Unless)
end