class Paginate < Liquid::Block
  Syntax     = /(#{Liquid::QuotedFragment})\s*(by\s*(\d+))?/

  def initialize(tag_name, markup, tokens)
    @nodelist = []
    
    if markup =~ Syntax
      @collection_name = $1
      @page_size = if $2
        $3.to_i
      else
        20
      end
      
      @attributes = { 'window_size' => 3 }
      markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = value
      end        
    else
      raise SyntaxError.new("Syntax Error in tag 'paginate' - Valid syntax: paginate [collection] by number")
    end
  
    super
  end

  def render(context)
    @context = context

    context.stack do                      
      current_page  = context['current_page'].to_i

      pagination = {
        'page_size'      => @page_size,
        'current_page'   => 5,
        'current_offset' => @page_size * 5
      }
      
      context['paginate'] = pagination      
      
      collection_size  = context[@collection_name].size      

      raise ArgumentError.new("Cannot paginate array '#{@collection_name}'. Not found.") if collection_size.nil?
    
      page_count = (collection_size.to_f / @page_size.to_f).to_f.ceil + 1 

      pagination['items']      = collection_size
      pagination['pages']      = page_count -1
      pagination['previous']   = link('&laquo; Previous', current_page-1 )  unless 1 >= current_page
      pagination['next']       = link('Next &raquo;', current_page+1 )      unless page_count <= current_page+1
      pagination['parts']      = []
      
      hellip_break = false
      
      if page_count > 2
        1.upto(page_count-1) do |page|          
        
          if current_page == page
            pagination['parts'] << no_link(page)        
          elsif page == 1 
            pagination['parts'] << link(page, page)
          elsif page == page_count -1
            pagination['parts'] << link(page, page)
          elsif page <= current_page - @attributes['window_size'] or page >= current_page + @attributes['window_size']
            next if hellip_break
            pagination['parts'] << no_link('&hellip;') 
            hellip_break = true
            next
          else
            pagination['parts'] << link(page, page)
          end
        
          hellip_break = false
        end 
      end
      
      render_all(@nodelist, context)      
    end
  end
    
  private
  
  def no_link(title)
    { 'title' => title, 'is_link' => false}
  end
  
  def link(title, page)
    { 'title' => title, 'url' => current_url + "?page=#{page}", 'is_link' => true}
  end
  
  def current_url
    "/collections/frontpage"
  end
end    