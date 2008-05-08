module Liquid

  # "For" iterates over an array or collection. 
  # Several useful variables are available to you within the loop.
  #
  # == Basic usage:
  #    {% for item in collection %}
  #      {{ forloop.index }}: {{ item.name }}
  #    {% endfor %}
  #
  # == Advanced usage:
  #    {% for item in collection %}
  #      <div {% if forloop.first %}class="first"{% endif %}>
  #        Item {{ forloop.index }}: {{ item.name }}
  #      </div>
  #    {% endfor %}
  #
  # You can also define a limit and offset much like SQL.  Remember
  # that offset starts at 0 for the first item.
  #
  #    {% for item in collection limit:5 offset:10 %}
  #      {{ item.name }}
  #    {% end %}
  #
  # == Available variables:
  #
  # forloop.name:: 'item-collection'
  # forloop.length:: Length of the loop
  # forloop.index:: The current item's position in the collection;
  #                 forloop.index starts at 1. 
  #                 This is helpful for non-programmers who start believe
  #                 the first item in an array is 1, not 0.
  # forloop.index0:: The current item's position in the collection
  #                  where the first item is 0
  # forloop.rindex:: Number of items remaining in the loop
  #                  (length - index) where 1 is the last item.
  # forloop.rindex0:: Number of items remaining in the loop
  #                   where 0 is the last item.
  # forloop.first:: Returns true if the item is the first item.
  # forloop.last:: Returns true if the item is the last item.
  #
  class For < Block                                             
    Syntax = /(\w+)\s+in\s+(#{VariableSignature}+)/   
  
    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @variable_name = $1
        @collection_name = $2
        @name = "#{$1}-#{$2}"
        @attributes = {}
        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end        
      else
        raise SyntaxError.new("Syntax Error in 'for loop' - Valid syntax: for [item] in [collection]")
      end

      super
    end
  
    def render(context)        
      context.registers[:for] ||= Hash.new(0)
    
      collection = context[@collection_name]
      collection = collection.to_a if collection.is_a?(Range)
    
      return '' if collection.nil? or collection.empty?
    
      range = (0..collection.length)
    
      if @attributes['limit'] or @attributes['offset']
        offset = 0
        if @attributes['offset'] == 'continue'
          offset = context.registers[:for][@name] 
        else          
          offset = context[@attributes['offset']] || 0
        end
        limit  = context[@attributes['limit']]

        range_end = limit ? offset + limit : collection.length
        range = (offset..range_end-1)
      
        # Save the range end in the registers so that future calls to 
        # offset:continue have something to pick up
        context.registers[:for][@name] = range_end
      end
            
      result = []
      segment = collection[range]
      return '' if segment.nil?        

      context.stack do 
        length = segment.length
      
        segment.each_with_index do |item, index|
          context[@variable_name] = item
          context['forloop'] = {
            'name'    => @name,
            'length'  => length,
            'index'   => index + 1, 
            'index0'  => index, 
            'rindex'  => length - index,
            'rindex0' => length - index -1,
            'first'   => (index == 0),
            'last'    => (index == length - 1) }
        
          result << render_all(@nodelist, context)
        end
      end
    
      # Store position of last element we rendered. This allows us to do 
    
      result 
    end           
  end

  Template.register_tag('for', For)
end