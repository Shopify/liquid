module Liquid

  # Assign sets a variable in your template.
  #
  #   {% assign foo = 'monkey' %}
  #
  # You can then use the variable later in the page.
  #
  #  {{ foo }}
  #
  class Assign < Tag
    Syntax = /(#{VariableSignature}+)\s*=\s*(.*)\s*/   
  
    def initialize(tag_name, markup, tokens)          
      if markup =~ Syntax
        @to = $1
        @from = Variable.new($2)
      else
        raise SyntaxError.new("Syntax Error in 'assign' - Valid syntax: assign [var] = [source]")
      end
      
      super      
    end
  
    def render(context)
      if Liquid::Defer === (x=context[@from.name])
        to = context[@from.name] || @from.name
        to = to.base if Liquid::Defer === to
        context.scopes.last[@to] = Liquid::Defer.new(@from.markup_with_name(to))
      else
        context.scopes.last[@to] = @from.render(context)
      end
      ''
    end 
  
  end  
  
  Template.register_tag('assign', Assign)  
end
