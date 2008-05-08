module ProductsFilter
  def price(integer)
    sprintf("$%.2d USD", integer / 100.0)
  end
  
  def prettyprint(text)
    text.gsub( /\*(.*)\*/, '<b>\1</b>' )
  end
  
  def count(array)
    array.size
  end
  
  def paragraph(p)
    "<p>#{p}</p>"
  end
end

class Servlet < LiquidServlet
  
  def index
    { 'date' => Time.now }
  end
  
  def products    
    { 'products' => products_list, 'section' => 'Snowboards', 'cool_products' => true}    
  end
  
  private
  
  def products_list
    [{'name' => 'Arbor Draft', 'price' => 39900, 'description' => 'the *arbor draft* is a excellent product' },
    {'name' => 'Arbor Element', 'price' => 40000, 'description' => 'the *arbor element* rocks for freestyling'},
    {'name' => 'Arbor Diamond', 'price' => 59900, 'description' => 'the *arbor diamond* is a made up product because im obsessed with arbor and have no creativity'}]
  end
  
end