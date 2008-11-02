module Liquid
  
  # Cycle is usually used within a loop to alternate between values, like colors or DOM classes.
  #
  #   {% for item in items %}
  #     <div class="{% cycle 'red', 'green', 'blue' %}"> {{ item }} </div>
  #   {% end %}
  #
  #    <div class="red"> Item one </div>
  #    <div class="green"> Item two </div>
  #    <div class="blue"> Item three </div>
  #    <div class="red"> Item four </div>
  #    <div class="green"> Item five</div>
  #
  class Cycle < Tag
    SimpleSyntax = /#{Expression}/        
    NamedSyntax = /(#{Expression})\s*\:\s*(.*)/
  
    def initialize(tag_name, markup, tokens)      
      case markup
      when NamedSyntax
      	@variables = variables_from_string($2)
      	@name = $1
      when SimpleSyntax
        @variables = variables_from_string(markup)
      	@name = "'#{@variables.to_s}'"
      else
        raise SyntaxError.new("Syntax Error in 'cycle' - Valid syntax: cycle [name :] var [, var2, var3 ...]")
      end

      super    
    end    
  
    def render(context)
      context.registers[:cycle] ||= Hash.new(0)
    
      context.stack do
        key = context[@name]	
        iteration = context.registers[:cycle][key]
        result = context[@variables[iteration]]
        iteration += 1    
        iteration  = 0  if iteration >= @variables.size 
        context.registers[:cycle][key] = iteration
        result 
      end
    end
  
    private
  
    def variables_from_string(markup)
      markup.split(',').collect do |var|
    	  var =~ /\s*(#{Expression})\s*/
    	  $1 ? $1 : nil
    	end.compact
    end
  
  end
  
  Template.register_tag('cycle', Cycle)
end