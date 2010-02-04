module ShopFilter
      
  def asset_url(input)
    "/files/1/[shop_id]/[shop_id]/assets/#{input}"
  end

  def global_asset_url(input)
    "/global/#{input}"
  end
  
  def shopify_asset_url(input)
    "/shopify/#{input}"
  end
  
  def script_tag(url)
    %(<script src="#{url}" type="text/javascript"></script>)
  end

  def stylesheet_tag(url, media="all")
    %(<link href="#{url}" rel="stylesheet" type="text/css"  media="#{media}"  />)
  end
       
  def link_to(link, url, title="")
    %|<a href="#{url}" title="#{title}">#{link}</a>|
  end
  
  def img_tag(url, alt="")
    %|<img src="#{url}" alt="#{alt}" />|  
  end  
  
  def link_to_vendor(vendor)
    if vendor
      link_to vendor, url_for_vendor(vendor), vendor
    else
      'Unknown Vendor'
    end
  end
  
  def link_to_type(type)
    if type
      link_to type, url_for_type(type), type
    else
      'Unknown Vendor'
    end
  end
  
  def url_for_vendor(vendor_title)
    "/collections/#{vendor_title.to_handle}"
  end
  
  def url_for_type(type_title)
    "/collections/#{type_title.to_handle}"
  end
  
  def product_img_url(url, style = 'small')
    
    unless url =~ /^products\/([\w\-\_]+)\.(\w{2,4})/
      raise ArgumentError, 'filter "size" can only be called on product images'
    end
    
    case style
    when 'original'
      return '/files/shops/random_number/' + url 
    when 'grande', 'large', 'medium', 'compact', 'small', 'thumb', 'icon'
      "/files/shops/random_number/products/#{$1}_#{style}.#{$2}"              
    else
      raise ArgumentError, 'valid parameters for filter "size" are: original, grande, large, medium, compact, small, thumb and icon '      
    end
  end
  
  def default_pagination(paginate)
    
    html = []    
    html << %(<span class="prev">#{link_to(paginate['previous']['title'], paginate['previous']['url'])}</span>) if paginate['previous']

    for part in paginate['parts']

      if part['is_link']
        html << %(<span class="page">#{link_to(part['title'], part['url'])}</span>)        
      elsif part['title'].to_i == paginate['current_page'].to_i
        html << %(<span class="page current">#{part['title']}</span>)        
      else
        html << %(<span class="deco">#{part['title']}</span>)                
      end
      
    end

    html << %(<span class="next">#{link_to(paginate['next']['title'], paginate['next']['url'])}</span>) if paginate['next']
    html.join(' ')
  end
  
  # Accepts a number, and two words - one for singular, one for plural
  # Returns the singular word if input equals 1, otherwise plural
  def pluralize(input, singular, plural)
    input == 1 ? singular : plural
  end
      
end
