# frozen_string_literal: true

module Liquid
  module Utils
    def self.slice_collection(collection, from, to)
      if (from != 0 || !to.nil?) && collection.respond_to?(:load_slice)
        collection.load_slice(from, to)
      else
        slice_collection_using_each(collection, from, to)
      end
    end

    def self.slice_collection_using_each(collection, from, to)
      segments = []
      index    = 0

      # Maintains Ruby 1.8.7 String#each behaviour on 1.9
      if collection.is_a?(String)
        return collection.empty? ? [] : [collection]
      end
      return [] unless collection.respond_to?(:each)

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

    def self.to_integer(num)
      return num if num.is_a?(Integer)
      num = num.to_s
      begin
        Integer(num)
      rescue ::ArgumentError
        raise Liquid::ArgumentError, "invalid integer"
      end
    end

    def self.to_number(obj)
      case obj
      when Float
        BigDecimal(obj.to_s)
      when Numeric
        obj
      when String
        /\A-?\d+\.\d+\z/.match?(obj.strip) ? BigDecimal(obj) : obj.to_i
      else
        if obj.respond_to?(:to_number)
          obj.to_number
        else
          0
        end
      end
    end

    def self.to_date(obj)
      return obj if obj.respond_to?(:strftime)

      if obj.is_a?(String)
        return nil if obj.empty?
        obj = obj.downcase
      end

      case obj
      when 'now', 'today'
        Time.now
      when /\A\d+\z/, Integer
        Time.at(obj.to_i)
      when String
        Time.parse(obj)
      end
    rescue ::ArgumentError
      nil
    end

    def self.to_liquid_value(obj)
      # Enable "obj" to represent itself as a primitive value like integer, string, or boolean
      return obj.to_liquid_value if obj.respond_to?(:to_liquid_value)

      # Otherwise return the object itself
      obj
    end

    def self.to_s(obj, seen = {})
      case obj
      when Hash
        # If the custom hash implementation overrides `#to_s`, use their
        # custom implementation. Otherwise we use Liquid's default
        # implementation.
        if obj.class.instance_method(:to_s) == HASH_TO_S_METHOD
          hash_inspect(obj, seen)
        else
          obj.to_s
        end
      when Array
        array_inspect(obj, seen)
      else
        obj.to_s
      end
    end

    def self.inspect(obj, seen = {})
      case obj
      when Hash
        # If the custom hash implementation overrides `#inspect`, use their
        # custom implementation. Otherwise we use Liquid's default
        # implementation.
        if obj.class.instance_method(:inspect) == HASH_INSPECT_METHOD
          hash_inspect(obj, seen)
        else
          obj.inspect
        end
      when Array
        array_inspect(obj, seen)
      else
        obj.inspect
      end
    end

    def self.array_inspect(arr, seen = {})
      if seen[arr.object_id]
        return "[...]"
      end

      seen[arr.object_id] = true
      str = +"["
      cursor = 0
      len = arr.length

      while cursor < len
        if cursor > 0
          str << ", "
        end

        item_str = inspect(arr[cursor], seen)
        str << item_str
        cursor += 1
      end

      str << "]"
      str
    ensure
      seen.delete(arr.object_id)
    end

    def self.hash_inspect(hash, seen = {})
      if seen[hash.object_id]
        return "{...}"
      end
      seen[hash.object_id] = true

      str = +"{"
      first = true
      hash.each do |key, value|
        if first
          first = false
        else
          str << ", "
        end

        key_str = inspect(key, seen)
        str << key_str
        str << "=>"

        value_str = inspect(value, seen)
        str << value_str
      end
      str << "}"
      str
    ensure
      seen.delete(hash.object_id)
    end

    HASH_TO_S_METHOD = Hash.instance_method(:to_s)
    private_constant :HASH_TO_S_METHOD

    HASH_INSPECT_METHOD = Hash.instance_method(:inspect)
    private_constant :HASH_INSPECT_METHOD
  end
end
