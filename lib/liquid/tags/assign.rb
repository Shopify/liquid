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
      if context['__defer_assignment__']
        resolved = context[@from.name] || @from.name
        resolved = resolved.base if Liquid::Defer === resolved

        context.scopes.last[@to] = Liquid::Defer.new(@to)

        return "{% assign #{@to} = #{resolved.inspect} %}"
      elsif Liquid::Defer === (x=context[@from.name])
        resolved = context[@from.name] || @from.name
        resolved = resolved.base if Liquid::Defer === resolved
        context.scopes.last[@to] = Liquid::Defer.new(@from.markup_with_name(resolved))
      else
        context.scopes.last[@to] = @from.render(context)
      end
      return '' unless context.intermediate
    end 
  
  end  
  
  Template.register_tag('assign', Assign)  
end
