# frozen_string_literal: true

require 'yaml'

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

      # From vision source
      db['products'].each do |product|
        collections = db['collections'].find_all do |collection|
          collection['products'].any? { |p| p['id'].to_i == product['id'].to_i }
        end
        product['collections'] = collections
      end

      # key the tables by handles, as this is how liquid expects it.
      db = db.each_with_object({}) do |(key, values), assigns|
        assigns[key] = values.each_with_object({}) do |v, h|
          h[v['handle']] = v
        end
      end

      # Some standard direct accessors so that the specialized templates
      # render correctly
      db['collection'] = db['collections'].values.first
      db['product']    = db['products'].values.first
      db['blog']       = db['blogs'].values.first
      db['article']    = db['blog']['articles'].first

      db['cart']       = {
        'total_price' => db['line_items'].values.inject(0) { |sum, item| sum + item['line_price'] * item['quantity'] },
        'item_count' => db['line_items'].values.inject(0) { |sum, item| sum + item['quantity'] },
        'items' => db['line_items'].values,
      }

      db
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  p(Database.tables['collections']['frontpage'].keys)
  # p Database.tables['blog']['articles']
end
