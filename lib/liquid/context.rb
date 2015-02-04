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
    attr_reader :scopes, :errors, :registers, :environments, :resource_limits
    attr_accessor :exception_handler

    def initialize(environments = {}, outer_scope = {}, registers = {}, rethrow_errors = false, resource_limits = nil)
      @environments     = [environments].flatten
      @scopes           = [(outer_scope || {})]
      @registers        = registers
      @errors           = []
      @resource_limits  = resource_limits || Template.default_resource_limits.dup
      @resource_limits[:render_score_current] = 0
      @resource_limits[:assign_score_current] = 0
      @parsed_expression = Hash.new{ |cache, markup| cache[markup] = Expression.parse(markup) }
      squash_instance_assigns_with_environments

      @this_stack_used = false

      if rethrow_errors
        self.exception_handler = ->(e) { true }
      end

      @interrupts = []
      @filters = []
    end

    def increment_used_resources(key, obj)
      @resource_limits[key] += if obj.kind_of?(String) || obj.kind_of?(Array) || obj.kind_of?(Hash)
        obj.length
      else
        1
      end
    end

    def resource_limits_reached?
      (@resource_limits[:render_length_limit] && @resource_limits[:render_length_current] > @resource_limits[:render_length_limit]) ||
      (@resource_limits[:render_score_limit]  && @resource_limits[:render_score_current]  > @resource_limits[:render_score_limit] ) ||
      (@resource_limits[:assign_score_limit]  && @resource_limits[:assign_score_current]  > @resource_limits[:assign_score_limit] )
    end

    def strainer
      @strainer ||= Strainer.create(self, @filters)
    end

    # Adds filters to this context.
    #
    # Note that this does not register the filters with the main Template object. see <tt>Template.register_filter</tt>
    # for that
    def add_filters(filters)
      filters = [filters].flatten.compact
      @filters += filters
      @strainer = nil
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


    def handle_error(e, token=nil)
      if e.is_a?(Liquid::Error)
        e.set_line_number_from_token(token)
      end

      errors.push(e)
      raise if exception_handler && exception_handler.call(e)
      Liquid::Error.render(e)
    end

    def invoke(method, *args)
      strainer.invoke(method, *args).to_liquid
    end

    # Push new local scope on the stack. use <tt>Context#stack</tt> instead
    def push(new_scope={})
      @scopes.unshift(new_scope)
      raise StackLevelError, "Nesting too deep".freeze if @scopes.length > 100
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
    def stack(new_scope=nil)
      old_stack_used = @this_stack_used
      if new_scope
        push(new_scope)
        @this_stack_used = true
      else
        @this_stack_used = false
      end

      yield
    ensure
      pop if @this_stack_used
      @this_stack_used = old_stack_used
    end

    def clear_instance_assigns
      @scopes[0] = {}
    end

    # Only allow String, Numeric, Hash, Array, Proc, Boolean or <tt>Liquid::Drop</tt>
    def []=(key, value)
      unless @this_stack_used
        @this_stack_used = true
        push({})
      end
      @scopes[0][key] = value
    end

    # Look up variable, either resolve directly after considering the name. We can directly handle
    # Strings, digits, floats and booleans (true,false).
    # If no match is made we lookup the variable in the current scope and
    # later move up to the parent blocks to see if we can resolve the variable somewhere up the tree.
    # Some special keywords return symbols. Those symbols are to be called on the rhs object in expressions
    #
    # Example:
    #   products == empty #=> products.empty?
    def [](expression)
      evaluate(@parsed_expression[expression])
    end

    def has_key?(key)
      self[key] != nil
    end

    def evaluate(object)
      object.respond_to?(:evaluate) ? object.evaluate(self) : object
    end

    # Fetches an object starting at the local scope and then moving up the hierachy
    def find_variable(key)

      # This was changed from find() to find_index() because this is a very hot
      # path and find_index() is optimized in MRI to reduce object allocation
      index = @scopes.find_index { |s| s.has_key?(key) }
      scope = @scopes[index] if index

      variable = nil

      if scope.nil?
        @environments.each do |e|
          variable = lookup_and_evaluate(e, key)
          unless variable.nil?
            scope = e
            break
          end
        end
      end

      scope     ||= @environments.last || @scopes.last
      variable  ||= lookup_and_evaluate(scope, key)

      variable = variable.to_liquid
      variable.context = self if variable.respond_to?(:context=)

      return variable
    end

    def lookup_and_evaluate(obj, key)
      if (value = obj[key]).is_a?(Proc) && obj.respond_to?(:[]=)
        obj[key] = (value.arity == 0) ? value.call : value.call(self)
      else
        value
      end
    end

    private
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
