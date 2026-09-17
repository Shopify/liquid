# frozen_string_literal: true

module Liquid
  module Utils
    DECIMAL_REGEX = /\A-?\d+\.\d+\z/
    UNIX_TIMESTAMP_REGEX = /\A-?\d+\z/

    def self.slice_collection(collection, from, to)
      if (from != 0 || !to.nil?) && collection.respond_to?(:load_slice)
        collection.load_slice(from, to)
      else
        slice_collection_using_each(collection, from, to)
      end
    end

    # This is intentionally separate from slice_collection, whose Array-returning
    # behavior is used outside of the iteration tags.
    def self.slice_collection_for_iteration(
      collection, from, to, resource_limits, allow_endless: false, use_range_to_a: false
    )
      if integer_range?(collection)
        RangeSlice.new(collection, from, to, resource_limits)
      elsif collection.is_a?(Range)
        if use_range_to_a && range_method_overridden?(collection, :to_a)
          # For historically honored custom Range#to_a. Charge the resulting
          # selection before buffering it, just as for a custom #each.
          slice_collection_for_iteration_using_each(collection.to_a, from, to, resource_limits)
        else
          slice_range_using_each(collection, from, to, resource_limits, allow_endless: allow_endless)
        end
      else
        slice_collection(collection, from, to)
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

    # Arithmetic slicing must not bypass a Range subclass's custom #each.
    def self.integer_range?(collection)
      collection.instance_of?(Range) && collection.begin.is_a?(Integer) && collection.end.is_a?(Integer)
    end
    private_class_method :integer_range?

    # Preserve support for Ruby-supplied string ranges and custom Range#each.
    # Their selected length cannot be inferred from integer bounds, but the tags
    # need it before rendering for loop metadata, continuation offsets, and columns.
    # Buffer the selection so we do not have to replay a potentially custom iterator.
    def self.slice_range_using_each(collection, from, to, resource_limits, allow_endless:)
      # TableRow historically accepted an endless subclass when its custom #each
      # was finite, while For historically raised through Range#to_a.
      if collection.end.nil? && !(allow_endless && (!to.nil? || range_method_overridden?(collection, :each)))
        raise RangeError, "cannot convert endless range to an array"
      end
      if collection.begin.nil? && !range_method_overridden?(collection, :each)
        raise TypeError, "can't iterate from NilClass"
      end

      slice_collection_for_iteration_using_each(collection, from, to, resource_limits)
    end
    private_class_method :slice_range_using_each

    # Custom Range#each can make a nominally beginless range finite; standard
    # beginless ranges were rejected before reaching this budgeted traversal.
    def self.slice_collection_for_iteration_using_each(collection, from, to, resource_limits)
      return [] if to && to <= from

      segments = []
      index = 0
      collection.each do |item|
        break if to && to <= index

        # Charge preparation, including skipped offsets, before buffering; checking
        # only while rendering the buffered values would leave this work unbudgeted.
        resource_limits.increment_render_score(1)
        segments << item if from <= index
        index += 1
      end
      segments
    end
    private_class_method :slice_collection_for_iteration_using_each

    def self.range_method_overridden?(collection, method_name)
      collection.method(method_name).owner != Range.instance_method(method_name).owner
    end
    private_class_method :range_method_overridden?

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
        DECIMAL_REGEX.match?(obj.strip) ? BigDecimal(obj) : obj.to_i
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
        return if obj.empty?
        obj = obj.downcase
      end

      case obj
      when 'now', 'today'
        Time.now
      when UNIX_TIMESTAMP_REGEX, Integer
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
      when BigDecimal
        obj.to_s("F")
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
