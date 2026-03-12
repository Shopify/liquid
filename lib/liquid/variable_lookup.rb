# frozen_string_literal: true

module Liquid
  class VariableLookup
    COMMAND_METHODS = ['size', 'first', 'last'].freeze

    attr_reader :name, :lookups

    def self.parse(markup, string_scanner = StringScanner.new(""), cache = nil)
      new(markup, string_scanner, cache)
    end

    # Fast parse that skips simple_lookup? check — caller guarantees simple identifier chain
    def self.parse_simple(markup, string_scanner = nil, cache = nil)
      new(markup, string_scanner, cache, true)
    end

    # Fast manual scanner replacing markup.scan(VariableParser)
    # VariableParser = /\[(?>[^\[\]]+|\g<0>)*\]|[\w-]+\??/
    # Splits "product.variants[0].title" into ["product", "variants", "[0]", "title"]
    def self.scan_variable(markup)
      result = []
      pos = 0
      len = markup.bytesize

      while pos < len
        byte = markup.getbyte(pos)

        if byte == 91 # '['
          # Scan balanced brackets
          depth = 1
          start = pos
          pos += 1
          while pos < len && depth > 0
            b = markup.getbyte(pos)
            if b == 91
              depth += 1
            elsif b == 93
              depth -= 1
            end
            pos += 1
          end
          if depth == 0
            result << markup.byteslice(start, pos - start)
          else
            # Unbalanced bracket - skip '[' and continue
            pos = start + 1
          end
        elsif byte == 46 # '.'
          pos += 1
        elsif (byte >= 97 && byte <= 122) || (byte >= 65 && byte <= 90) || (byte >= 48 && byte <= 57) || byte == 95 || byte == 45 # \w or -
          start = pos
          pos += 1
          while pos < len
            b = markup.getbyte(pos)
            break unless (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || (b >= 48 && b <= 57) || b == 95 || b == 45
            pos += 1
          end
          # Check trailing '?'
          if pos < len && markup.getbyte(pos) == 63
            pos += 1
          end
          result << markup.byteslice(start, pos - start)
        else
          pos += 1
        end
      end

      result
    end

    # Check if markup is a simple identifier chain: [\w-]+\??(.[\w-]+\??)*
    # Uses C-level match? — 8x faster than Ruby byte scanning
    SIMPLE_LOOKUP_RE = /\A[\w-]+\??(?:\.[\w-]+\??)*\z/

    def self.simple_lookup?(markup)
      markup.bytesize > 0 && markup.match?(SIMPLE_LOOKUP_RE)
    end

    def initialize(markup, string_scanner = StringScanner.new(""), cache = nil, simple = false)
      # Fast path: simple identifier chain without brackets
      if simple || self.class.simple_lookup?(markup)
        dot_pos = markup.index('.')
        if dot_pos.nil?
          @name = markup
          @lookups = Const::EMPTY_ARRAY
          @command_flags = 0
          return
        end
        @name = markup.byteslice(0, dot_pos)
        # Build lookups array from remaining dot-separated segments
        lookups = []
        @command_flags = 0
        pos = dot_pos + 1
        len = markup.bytesize
        while pos < len
          seg_start = pos
          while pos < len
            b = markup.getbyte(pos)
            break if b == 46 # '.'
            pos += 1
          end
          seg = markup.byteslice(seg_start, pos - seg_start)
          if COMMAND_METHODS.include?(seg)
            @command_flags |= 1 << lookups.length
          end
          lookups << seg
          pos += 1 # skip dot
        end
        @lookups = lookups
        return
      end

      lookups = self.class.scan_variable(markup)

      name = lookups.shift
      if name&.start_with?('[') && name&.end_with?(']')
        name = Expression.parse(
          name[1..-2],
          string_scanner,
          cache,
        )
      end
      @name = name

      @lookups       = lookups
      @command_flags = 0

      @lookups.each_index do |i|
        lookup = lookups[i]
        if lookup&.start_with?('[') && lookup&.end_with?(']')
          lookups[i] = Expression.parse(
            lookup[1..-2],
            string_scanner,
            cache,
          )
        elsif COMMAND_METHODS.include?(lookup)
          @command_flags |= 1 << i
        end
      end
    end

    def lookup_command?(lookup_index)
      @command_flags & (1 << lookup_index) != 0
    end

    def evaluate(context)
      name   = context.evaluate(@name)
      object = context.find_variable(name)

      @lookups.each_index do |i|
        lookup = @lookups[i]
        key = lookup.instance_of?(String) ? lookup : context.evaluate(lookup)

        # Cast "key" to its liquid value to enable it to act as a primitive value
        # Fast path: strings and integers (most common key types) don't need conversion
        unless key.instance_of?(String) || key.instance_of?(Integer)
          key = Liquid::Utils.to_liquid_value(key)
        end

        # If object is a hash- or array-like object we look for the
        # presence of the key and if its available we return it
        if object.instance_of?(Hash) ? object.key?(key) :
            (object.respond_to?(:[]) &&
              ((object.respond_to?(:key?) && object.key?(key)) ||
               (object.respond_to?(:fetch) && key.is_a?(Integer))))

          # if its a proc we will replace the entry with the proc
          object = context.lookup_and_evaluate(object, key)
          # Skip to_liquid for common primitive types (they return self)
          unless object.instance_of?(String) || object.instance_of?(Integer) || object.instance_of?(Float) ||
              object.instance_of?(Array) || object.instance_of?(Hash) || object.nil?
            object = object.to_liquid
            object.context = context if object.respond_to?(:context=)
          end

          # Some special cases. If the part wasn't in square brackets and
          # no key with the same name was found we interpret following calls
          # as commands and call them on the current object
        elsif lookup_command?(i) && object.respond_to?(key)
          object = object.send(key)
          unless object.instance_of?(String) || object.instance_of?(Integer) || object.instance_of?(Array) || object.nil?
            object = object.to_liquid
            object.context = context if object.respond_to?(:context=)
          end

        # Handle string first/last like ActiveSupport does (returns first/last character)
        # ActiveSupport returns "" for empty strings, not nil
        elsif lookup_command?(i) && object.is_a?(String) && (key == "first" || key == "last")
          object = key == "first" ? (object[0] || "") : (object[-1] || "")

          # No key was present with the desired value and it wasn't one of the directly supported
          # keywords either. The only thing we got left is to return nil or
          # raise an exception if `strict_variables` option is set to true
        else
          return nil unless context.strict_variables
          raise Liquid::UndefinedVariable, "undefined variable #{key}"
        end
      end

      object
    end

    def ==(other)
      self.class == other.class && state == other.state
    end

    protected

    def state
      [@name, @lookups, @command_flags]
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        @node.lookups
      end
    end
  end
end
