module Liquid
  class Expression
    LITERALS = {
      nil => nil, 'nil'.freeze => nil, 'null'.freeze => nil, ''.freeze => nil,
      'true'.freeze  => true,
      'false'.freeze => false,
      'blank'.freeze => :blank?,
      'empty'.freeze => :empty?
    }
    SQUARE_BRACKETED = /\A\[(.*)\]\z/m
    COMMAND_METHODS = ['size'.freeze, 'first'.freeze, 'last'.freeze]

    def self.parse(markup)
      obj = new
      obj.parse(markup)
      obj
    end

    def initialize
      @instructions = []
    end

    def parse(markup)
      if LITERALS.key?(markup)
        @instructions << [:id, LITERALS[markup]]
      else
        case markup
        when /\A'(.*)'\z/m # Single quoted strings
          @instructions << [:id, $1]
        when /\A"(.*)"\z/m # Double quoted strings
          @instructions << [:id, $1]
        when /\A(-?\d+)\z/ # Integer
          @instructions << [:id, $1.to_i]
        when /\A\((\S+)\.\.(\S+)\)\z/ # Ranges
          left, right = $1, $2
          parse(left)
          parse(right)
          @instructions << [:range, nil]
        when /\A(-?\d[\d\.]+)\z/ # Floats
          @instructions << [:id, $1.to_f]
        else
          parse_variable(markup)
        end
      end
    end

    def evaluate(context)
      stack = []

      @instructions.each do |sym, value|
        case sym
        when :id
          stack.push(value)
        when :lookup
          left = stack.pop
          value = context.find_variable(left)

          stack.push(value)
        when :range
          right = stack.pop.to_i
          left  = stack.pop.to_i

          stack.push(left..right)
        when :builtin
          left = stack.pop

          value = invoke_builtin(context, left, value)

          stack.push(context.harden(value))
        when :call
          left = stack.pop
          right = stack.pop
          value = invoke(context, right, left)

          stack.push(context.harden(value))
        else
          raise "Unknown expression instruction #{sym}"
        end
      end

      stack.first
    end

    private

    def parse_variable(markup)
      lookups = markup.scan(VariableParser)

      name = lookups.shift
      if name =~ SQUARE_BRACKETED
        parse($1)
      else
        @instructions << [:id, name]
      end
      @instructions << [:lookup, nil]

      lookups.each do |lookup|
        if lookup =~ SQUARE_BRACKETED
          parse($1)
          @instructions << [:call, nil]
        elsif COMMAND_METHODS.include?(lookup)
          @instructions << [:builtin, lookup]
        else
          @instructions << [:id, lookup] << [:call, nil]
        end
      end
    end

    def invoke_builtin(context, obj, key)
      # as weird as this is, liquid unit tests demand that we prioritize hash lookups
      # to builtins. So if we got a hash and it has a :first element we need to call that
      # instead of sending the first message...

      if obj.respond_to?(:has_key?) && obj.has_key?(key)
        context.lookup_and_evaluate(obj, key)
      elsif obj.respond_to?(key)
        obj.send(key)
      else
        nil
      end
    end

    def invoke(context, object, key)
      # If object is a hash- or array-like object we look for the
      # presence of the key and if its available we return it
      if object.respond_to?(:[]) &&
        ((object.respond_to?(:has_key?) && object.has_key?(key)) ||
         (object.respond_to?(:fetch) && key.is_a?(Integer)))

        context.lookup_and_evaluate(object, key)
      else
        nil
      end
    end
  end
end
