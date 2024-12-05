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
    { 'date' => Time.now, 'products' => products_list }
  end

  def products
    { 'products' => products_list, 'more_products' => more_products_list, 'description' => description, 'section' => 'Snowboards', 'cool_products' => true }
  end

  private

  class Name < Liquid::Drop
    attr_reader :raw, :origin

    def initialize(raw, origin)
      super()
      @raw = raw
      @origin = origin
    end
  end

  class Price < Liquid::Drop
    attr_reader :value, :unit

    def initialize(value, unit = 'USD')
      super()
      @value = value
      @unit = unit
    end
  end

  class Product < Liquid::Drop
    attr_reader :name, :price, :description

    def initialize(name, origin, price, description)
      super()
      @name = Name.new(name, origin)
      @price = Price.new(price)
      @description = description
    end
  end

  def products_list
    [
      { 'name' => 'Alpine jacket',  'price' => { 'value' => 30000, 'unit' => 'USD' }, 'description' => 'the *alpine jacket* is a excellent product' },
      { 'name' => 'Mountain boots', 'price' => { 'value' => 40000, 'unit' => 'BRL' }, 'description' => 'the *mountain boots* are perfect for hiking' },
      { 'name' => 'Safety helmet',  'price' => { 'value' => 10000, 'unit' => 'USD' }, 'description' => 'the *safety helmet* provides essential protection for winter sports' }
    ]
  end

  def more_products_list
    [
      { 'name' => 'Arbor Catalyst', 'price' => 39900, 'description' => 'the *arbor catalyst* is an advanced drop-through for freestyle and flatground performance and versatility' },
      { 'name' => 'Arbor Fish', 'price' => 40000, 'description' => 'the *arbor fish* is a compact pin that features an extended wheelbase and time-honored teardrop shape' }
    ]
  end

  def description
    "List of Products ~ This is a list of products with price and description."
  end
end
