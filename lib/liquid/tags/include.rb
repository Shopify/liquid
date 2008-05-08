module Liquid
  class Include < Tag
    Syntax = /(#{QuotedFragment}+)(\s+(?:with|for)\s+(#{QuotedFragment}+))?/
  
    def initialize(tag_name, markup, tokens)      
      if markup =~ Syntax

        @template_name = $1        
        @variable_name = $3
        @attributes    = {}

        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end

      else
        raise SyntaxError.new("Error in tag 'include' - Valid syntax: include '[template]' (with|for) [object|collection]")
      end

      super
    end
  
    def parse(tokens)      
    end
  
    def render(context)      
      source  = Liquid::Template.file_system.read_template_file(context[@template_name])      
      partial = Liquid::Template.parse(source)      
      
      variable = context[@variable_name || @template_name[1..-2]]
      
      context.stack do
        @attributes.each do |key, value|
          context[key] = context[value]
        end

        if variable.is_a?(Array)
          
          variable.collect do |variable|            
            context[@template_name[1..-2]] = variable
            partial.render(context)
          end

        else
                    
          context[@template_name[1..-2]] = variable
          partial.render(context)
          
        end
      end
    end
  end

  Template.register_tag('include', Include)  
end