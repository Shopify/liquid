module Liquid
  module Utils

    def self.slice_collection(collection, from, to)
      if (from != 0 || to != nil) && collection.respond_to?(:load_slice)
        collection.load_slice(from, to)
      else
        slice_collection_using_each(collection, from, to)
      end
    end

    def self.non_blank_string?(collection)
      collection.is_a?(String) && collection != ''.freeze
    end

    def self.slice_collection_using_each(collection, from, to)
      segments = []
      index = 0

      # Maintains Ruby 1.8.7 String#each behaviour on 1.9
      return [collection] if non_blank_string?(collection)

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
  end
end
