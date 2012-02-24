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
  #    {% else %}
  #      There is nothing in the collection.
  #    {% endfor %}
  #
  # You can also define a limit and offset much like SQL.  Remember
  # that offset starts at 0 for the first item.
  #
  #    {% for item in collection limit:5 offset:10 %}
  #      {{ item.name }}
  #    {% end %}             
  #
  # You can also specify an order for the collection items
  #
  #    {% for item in collection order:ascending %}
  #      {{ item.name }}
  #    {% end %}
  #
  # You can also specify which attribute to sort by.
  #
  #    {% for item in collection sort_by:name order:descending %}
  #      {{ item.name }}
  #    {% end %}
  #
  # To reverse the for loop simply use {% for item in collection reversed %}
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
    Syntax = /(\w+)\s+in\s+(#{QuotedFragment}+)\s*(reversed)?/   
  
    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @variable_name = $1
        @collection_name = $2
        @name = "#{$1}-#{$2}"           
        @reversed = $3             
        @attributes = {}
        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end
        @reversed = 'reversed' if @attributes['order'] == 'descending'
      else
        raise SyntaxError.new("Syntax Error in 'for loop' - Valid syntax: for [item] in [collection]")
      end

      @nodelist = @for_block = []
      super
    end

    def unknown_tag(tag, markup, tokens)
      return super unless tag == 'else'
      @nodelist = @else_block = []
    end
  
    def render(context)        
      context.registers[:for] ||= Hash.new(0)
    
      collection = context[@collection_name]
      collection = collection.to_a if collection.is_a?(Range)
    
      # Maintains Ruby 1.8.7 String#each behaviour on 1.9
      return render_else(context) unless collection.respond_to?(:each) or collection.is_a?(String)

      sort_property = @attributes['sort_by']
      order_property = @attributes['order']
      if sort_property || order_property
        collection = if sort_property.nil? && (@attributes['order'] == 'ascending' || @attributes['order'] == 'descending')
          collection.sort
        elsif collection.first.respond_to?('[]') and !collection.first[sort_property].nil?
          collection.sort {|a,b| a[sort_property] <=> b[sort_property] }
        elsif collection.first.respond_to?(sort_property)
          collection.sort {|a,b| a.send(sort_property) <=> b.send(sort_property) }
        else
          collection
        end
      end

      collection.reverse! if @reversed

      from = if @attributes['offset'] == 'continue'
        context.registers[:for][@name].to_i
      else
        context[@attributes['offset']].to_i
      end
        
      limit = context[@attributes['limit']]
      to    = limit ? limit.to_i + from : nil  
          
                       
      segment = slice_collection_using_each(collection, from, to)      
      
      return render_else(context) if segment.empty?
      
      result = ''
        
      length = segment.length            
            
      # Store our progress through the collection for the continue flag
      context.registers[:for][@name] = from + segment.length
              
      context.stack do 
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

          result << render_all(@for_block, context)
        end
      end
      result     
    end          
        
    def slice_collection_using_each(collection, from, to)       
      segments = []      
      index = 0      
      yielded = 0

      # Maintains Ruby 1.8.7 String#each behaviour on 1.9
      return [collection] if collection.is_a?(String)

      collection.each do |item|         
                
        if to && to <= index
          break
        end
        
        if from <= index                               
          segments << item
        end                    
                
        index += 1
      end    

      segments
    end

    private

      def render_else(context)
        return @else_block ? [render_all(@else_block, context)] : ''
      end

  end

  Template.register_tag('for', For)
end
