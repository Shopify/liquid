# frozen_string_literal: true

module ProductsFilter
  def price(integer)
    format("$%.2d USD", integer / 100.0)
  end

  def prettyprint(text)
    text.gsub(/\*(.*)\*/, '<b>\1</b>')
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
    { 'products' => products_list, 'more_products' => more_products_list, 'description' => description, 'section' => 'Snowboards', 'cool_products' => true }
  end

  private

  def products_list
    [{ 'name' => 'Arbor Draft', 'price' => 39900, 'description' => 'the *arbor draft* is a excellent product' },
     { 'name' => 'Arbor Element', 'price' => 40000, 'description' => 'the *arbor element* rocks for freestyling' },
     { 'name' => 'Arbor Diamond', 'price' => 59900, 'description' => 'the *arbor diamond* is a made up product because im obsessed with arbor and have no creativity' }]
  end

  def more_products_list
    [{ 'name' => 'Arbor Catalyst', 'price' => 39900, 'description' => 'the *arbor catalyst* is an advanced drop-through for freestyle and flatground performance and versatility' },
     { 'name' => 'Arbor Fish', 'price' => 40000, 'description' => 'the *arbor fish* is a compact pin that features an extended wheelbase and time-honored teardrop shape' }]
  end

  def description
    "List of Products ~ This is a list of products with price and description."
  end
end
