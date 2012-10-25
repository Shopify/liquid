module Liquid

  
  # Context keeps the variable stack and resolves variables, as well as keywords
  #
  #   context['variable'] = 'testing'
  #   context['variable'] #=> 'testing'
  #   context['true']     #=> true
  #   context['10.2232']  #=> 10.2232
  #
  #   context.stack do
  #      context['bob'] = 'bobsen'
  #   end
  #
  #   context['bob']  #=> nil  class Context
  class Context
    attr_reader :scopes, :errors, :registers, :environments

    def initialize(environments = {}, outer_scope = {}, registers = {}, rethrow_errors = false)
      @environments   = [environments].flatten
      @scopes         = [(outer_scope || {})]
      @registers      = registers
      @errors         = []
      @rethrow_errors = rethrow_errors
      squash_instance_assigns_with_environments

      @interrupts = []
    end

    def strainer
      @strainer ||= Strainer.create(self)
    end

    # Adds filters to this context.
    #
    # Note that this does not register the filters with the main Template object. see <tt>Template.register_filter</tt>
    # for that
    def add_filters(filters)
      filters = [filters].flatten.compact

      filters.each do |f|
        raise ArgumentError, "Expected module but got: #{f.class}" unless f.is_a?(Module)
        Strainer.add_known_filter(f)
        strainer.extend(f)
      end
    end

    # are there any not handled interrupts?
    def has_interrupt?
      !@interrupts.empty?
    end

    # push an interrupt to the stack. this interrupt is considered not handled.
    def push_interrupt(e)
      @interrupts.push(e)
    end

    # pop an interrupt from the stack
    def pop_interrupt
      @interrupts.pop
    end

    def handle_error(e)
      errors.push(e)
      raise if @rethrow_errors

      case e
      when SyntaxError
        "Liquid syntax error: #{e.message}"
      else
        "Liquid error: #{e.message}"
      end
    end

    def invoke(method, *args)
      strainer.invoke(method, *args)
    end

    # Push new local scope on the stack. use <tt>Context#stack</tt> instead
    def push(new_scope={})
      @scopes.unshift(new_scope)
      raise StackLevelError, "Nesting too deep" if @scopes.length > 100
    end

    # Merge a hash of variables in the current local scope
    def merge(new_scopes)
      @scopes[0].merge!(new_scopes)
    end

    # Pop from the stack. use <tt>Context#stack</tt> instead
    def pop
      raise ContextError if @scopes.size == 1
      @scopes.shift
    end

    # Pushes a new local scope on the stack, pops it at the end of the block
    #
    # Example:
    #   context.stack do
    #      context['var'] = 'hi'
    #   end
    #
    #   context['var]  #=> nil
    def stack(new_scope={})
      push(new_scope)
      yield
    ensure
      pop
    end

    def clear_instance_assigns
      @scopes[0] = {}
    end

    # Only allow String, Numeric, Hash, Array, Proc, Boolean or <tt>Liquid::Drop</tt>
    def []=(key, value)
      @scopes[0][key] = value
    end

    def [](key)
      resolve(key)
    end

    def has_key?(key)
      resolve(key) != nil
    end

    private

      # Look up variable, either resolve directly after considering the name. We can directly handle
      # Strings, digits, floats and booleans (true,false).
      # If no match is made we lookup the variable in the current scope and
      # later move up to the parent blocks to see if we can resolve the variable somewhere up the tree.
      # Some special keywords return symbols. Those symbols are to be called on the rhs object in expressions
      #
      # Example:
      #   products == empty #=> products.empty?
      def resolve(key)        
        case key
        when nil, ""
          return nil
        when "blank"
          return :blank?
        when "empty"
          return :empty?
        end
        
        result = Parser.parse(key)   
        stack = []

        result.each do |(sym, value)|          

          case sym
          when :id
            stack.push value
          when :lookup
            left = stack.pop
            value = find_variable(left)
            
            stack.push(harden(value))
          when :range
            right = stack.pop.to_i
            left  = stack.pop.to_i
            
            stack.push (left..right)
          when :buildin
            left = stack.pop
            value = invoke_buildin(left, value)
            
            stack.push(harden(value))
          when :call
            left = stack.pop
            right = stack.pop
            value = lookup_and_evaluate(right, left)

            stack.push(harden(value))
          else 
            raise "unknown #{sym}"
          end
        end

        return stack.first
      end

      def invoke_buildin(obj, key)
        # as weird as this is, liquid unit tests demand that we prioritize hash lookups 
        # to buildins. So if we got a hash and it has a :first element we need to call that 
        # instead of sending the first message...

        if obj.respond_to?(:has_key?) && obj.has_key?(key)
          return lookup_and_evaluate(obj, key)
        end

        if obj.respond_to?(key) 
          return obj.send(key)
        else
          return nil    
        end
      end

      # Fetches an object starting at the local scope and then moving up the hierachy
      def find_variable(key)
        scope = @scopes.find { |s| s.has_key?(key) }

        if scope.nil?
          @environments.each do |e|
            if variable = lookup_and_evaluate(e, key)
              scope = e
              break
            end
          end
        end

        scope     ||= @environments.last || @scopes.last
        variable  ||= lookup_and_evaluate(scope, key)

        return variable
      end

      def lookup_and_evaluate(obj, key)
        return nil unless obj.respond_to?(:[])
        
        if obj.is_a?(Array)
          return nil unless key.is_a?(Integer)
        end

        value = obj[key]

        case value
        when Proc
          # call the proc
          value = (value.arity == 0) ? value.call : value.call(self)

          # memozie if possible
          obj[key] = value if obj.respond_to?(:[]=)
        end

        value
      end

      def harden(value)
        value = value.to_liquid
        value.context = self if value.respond_to?(:context=)
        return value
      end

      def squash_instance_assigns_with_environments
        @scopes.last.each_key do |k|
          @environments.each do |env|
            if env.has_key?(k)
              scopes.last[k] = lookup_and_evaluate(env, k)
              break
            end
          end
        end
      end # squash_instance_assigns_with_environments

  end # Context

end # Liquid
