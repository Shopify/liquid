module Liquid

  # Assign sets a variable in your template.
  #
  #   {% assign foo = 'monkey' %}
  #
  # You can then use the variable later in the page.
  #
  #  {{ monkey }}
  #
  class Assign < Tag
    Syntax = /(#{VariableSignature}+)\s*=\s*(#{Expression}+)/   
  
    def initialize(tag_name, markup, tokens)          
      if markup =~ Syntax
        @to = $1
        @from = $2
      else
        raise SyntaxError.new("Syntax Error in 'assign' - Valid syntax: assign [var] = [source]")
      end
      
      super      
    end
  
    def render(context)
       context.scopes.last[@to.to_s] = context[@from]
       ''
    end 
  
  end  
  
  Template.register_tag('assign', Assign)  
end