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
      new.parse(markup)
    end

    def initialize
      @instructions = []
      @stack = []
    end

    def parse(markup)
      if LITERALS.key?(markup)
        @instructions.push(:id, LITERALS[markup])
      else
        case markup
        when /\A'(.*)'\z/m # Single quoted strings
          @instructions.push(:id, $1)
        when /\A"(.*)"\z/m # Double quoted strings
          @instructions.push(:id, $1)
        when /\A(-?\d+)\z/ # Integer
          @instructions.push(:id, $1.to_i)
        when /\A\((\S+)\.\.(\S+)\)\z/ # Ranges
          left, right = $1, $2
          parse(left)
          parse(right)
          @instructions.push(:range, nil)
        when /\A(-?\d[\d\.]+)\z/ # Floats
          @instructions.push(:id, $1.to_f)
        else
          parse_variable(markup)
        end
      end
      self
    end

    def evaluate(context)
      @stack.clear 

      i = 0
      while i < @instructions.size
        sym = @instructions[i]
        value = @instructions[i + 1]
        case sym
        when :id
          @stack.push(value)
        when :lookup
          left = @stack.pop
          value = context.find_variable(left)

          @stack.push(value)
        when :range
          right = @stack.pop.to_i
          left  = @stack.pop.to_i

          @stack.push(left..right)
        when :builtin
          left = @stack.pop

          value = invoke_builtin(context, left, value)

          @stack.push(context.harden(value))
        when :call
          left = @stack.pop
          right = @stack.pop
          value = invoke(context, right, left)

          @stack.push(context.harden(value))
        else
          raise InternalError, "Unknown expression instruction #{sym}"
        end
        i += 2
      end

      @stack.first
    end

    private

    def parse_variable(markup)
      lookups = markup.scan(VariableParser)

      name = lookups.shift
      if name =~ SQUARE_BRACKETED
        parse($1)
      else
        @instructions.push(:id, name)
      end
      @instructions.push(:lookup, nil)

      lookups.each do |lookup|
        if lookup =~ SQUARE_BRACKETED
          parse($1)
          @instructions.push(:call, nil)
        elsif COMMAND_METHODS.include?(lookup)
          @instructions.push(:builtin, lookup)
        else
          @instructions.push(:id, lookup, :call, nil)
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
