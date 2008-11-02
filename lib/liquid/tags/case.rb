module Liquid
  class Case < Block
    Syntax     = /(#{Expression})/
    WhenSyntax = /(#{Expression})(?:(?:\s+or\s+|\s*\,\s*)(#{Expression}.*))?/

    def initialize(tag_name, markup, tokens)      
      @blocks = []
      
      if markup =~ Syntax
        @left = $1
      else
        raise SyntaxError.new("Syntax Error in tag 'case' - Valid syntax: case [condition]")
      end
            
      super
    end

    def unknown_tag(tag, markup, tokens)
      @nodelist = []
      case tag
      when 'when'
        record_when_condition(markup)
      when 'else'
        record_else_condition(markup)
      else
        super
      end
    end

    def render(context)      
      context.stack do          
        execute_else_block = true
        
        @blocks.inject([]) do |output, block|
      
          if block.else? 
            
            return render_all(block.attachment, context) if execute_else_block
            
          elsif block.evaluate(context)
            
            execute_else_block = false        
            output += render_all(block.attachment, context)                    
          end            
      
          output
        end
      end          
    end
    
    private
    
    def record_when_condition(markup)                
      while markup
      	# Create a new nodelist and assign it to the new block
      	if not markup =~ WhenSyntax
      	  raise SyntaxError.new("Syntax Error in tag 'case' - Valid when condition: {% when [condition] [or condition2...] %} ")
      	end

      	markup = $2

      	block = Condition.new(@left, '==', $1)        
      	block.attach(@nodelist)
      	@blocks.push(block)
      end
    end

    def record_else_condition(markup)            

      if not markup.strip.empty?
        raise SyntaxError.new("Syntax Error in tag 'case' - Valid else condition: {% else %} (no parameters) ")
      end
         
      block = ElseCondition.new            
      block.attach(@nodelist)
      @blocks << block
    end
    
        
  end    
  
  Template.register_tag('case', Case)
end
