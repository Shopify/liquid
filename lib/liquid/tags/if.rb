module Liquid

  # If is the conditional block
  #
  #   {% if user.admin %}
  #     Admin user!
  #   {% else %}
  #     Not admin user
  #   {% endif %}
  #
  #    There are {% if count < 5 %} less {% else %} more {% endif %} items than you need.
  #
  #
  class If < Block
    SyntaxHelp = "Syntax Error in tag 'if' - Valid syntax: if [expression]"
    Syntax = /(#{Expression})\s*([=!<>a-z_]+)?\s*(#{Expression})?/
    
    def initialize(tag_name, markup, tokens)    
    
      @blocks = []
      
      push_block('if', markup)
      
      super      
    end
    
    def unknown_tag(tag, markup, tokens)
      if ['elsif', 'else'].include?(tag)
        push_block(tag, markup)
      else
        super
      end
    end
    
    def render(context)
      context.stack do
        @blocks.each do |block|
          if block.evaluate(context)            
            return render_all(block.attachment, context)            
          end
        end 
        ''
      end
    end
    
    private
    
    def push_block(tag, markup)            
      block = if tag == 'else'
        ElseCondition.new
      else        
        
        expressions = markup.split(/\b(and|or)\b/).reverse
        raise(SyntaxError, SyntaxHelp) unless expressions.shift =~ Syntax 

        condition = Condition.new($1, $2, $3)               
        
        while not expressions.empty?
          operator = expressions.shift 
          
          raise(SyntaxError, SyntaxHelp) unless expressions.shift.to_s =~ Syntax    
          
          new_condition = Condition.new($1, $2, $3)
          new_condition.send(operator.to_sym, condition)     
          condition = new_condition          
        end                        
                  
        condition
      end
            
      @blocks.push(block)      
      @nodelist = block.attach(Array.new) 
    end
    
    
  end

  Template.register_tag('if', If)
end