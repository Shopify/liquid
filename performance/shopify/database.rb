# frozen_string_literal: true

require 'yaml'

class ProductDrop < Liquid::Drop
  def initialize(product, db)
    @product = product
    @db = db
  end

  def title
    @product['title']
  end

  def handle
    @product['handle']
  end

  def price
    @product['price']
  end

  def method_missing(method, *args, &block)
    @product[method.to_s]
  end

  def collections
    @db['collections'].find_all do |collection|
      collection['products'].any? { |p| p['id'].to_i == @product['id'].to_i }
    end
  end
end

module Database
  DATABASE_FILE_PATH = "#{__dir__}/vision.database.yml"

  # Load the standard vision toolkit database and re-arrage it to be simply exportable
  # to liquid as assigns. All this is based on Shopify
  def self.tables
    @tables ||= begin



      db =
        if YAML.respond_to?(:unsafe_load_file) # Only Psych 4+ can use unsafe_load_file
          # unsafe_load_file is needed for YAML references
          YAML.unsafe_load_file(DATABASE_FILE_PATH)
        else
          YAML.load_file(DATABASE_FILE_PATH)
        end


      # key the tables by handles, as this is how liquid expects it.
      db = db.each_with_object({}) do |(key, values), hash|
        hash[key] = values.each_with_object({}) do |v, h|
          h[v['handle']] = v
        end
      end

      assigns = {}

      # From vision source
      assigns['products'] = db['products'].inject({}) do |hash, (key, product)|
        hash[key] = ProductDrop.new(product, db)
        hash
      end

      assigns['product']    = assigns['products'].values.first
      assigns['blog']       = db['blogs'].values.first
      assigns['article']    = assigns['blog']['articles'].first

      # Some standard direct accessors so that the specialized templates
      # render correctly
      assigns['collection'] = db['collections'].values.first
      assigns['collection']['tags'] = assigns['collection']['products'].map { |product| product['tags'] }.flatten.uniq.sort

      assigns['tags'] = assigns['collection']['tags'][0..1]
      assigns['all_tags'] = db['products'].values.map { |product| product['tags'] }.flatten.uniq.sort
      assigns['current_tags'] = assigns['collection']['tags'][0..1]
      assigns['handle'] = assigns['collection']['handle']

      assigns['cart'] = {
        'total_price' => db['line_items'].values.inject(0) { |sum, item| sum + item['line_price'] * item['quantity'] },
        'item_count' => db['line_items'].values.inject(0) { |sum, item| sum + item['quantity'] },
        'items' => db['line_items'].values,
      }

      assigns['linklists'] = db['link_lists']

      assigns['shop'] = {
        'name' => 'Snowdevil',
        'currency' => 'USD',
        'money_format' => '${{amount}}',
        'money_with_currency_format' => '${{amount}} USD',
        'money_format_with_currency' => 'USD ${{amount}}',
      }

      assigns
    end
  end
end
