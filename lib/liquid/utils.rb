module Liquid
  module Utils
    def self.slice_collection_using_each(collection, from, to)
      segments = []
      index = 0
      yielded = 0

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

    def self.non_blank_string?(collection)
      collection.is_a?(String) && collection != ''
    end
  end
end
