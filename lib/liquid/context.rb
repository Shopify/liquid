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
    attr_reader :scope, :errors, :registers, :environments, :resource_limits
    attr_accessor :exception_renderer, :template_name, :partial, :global_filter, :strict_variables, :strict_filters

    def initialize(environments = {}, outer_scope = {}, registers = {}, rethrow_errors = false, resource_limits = nil)
      @environments     = [environments].flatten
      @scope            = outer_scope || {}
      @registers        = registers
      @errors           = []
      @partial          = false
      @strict_variables = false
      @resource_limits  = resource_limits || ResourceLimits.new(Template.default_resource_limits)
      squash_instance_assigns_with_environments

      self.exception_renderer = Template.default_exception_renderer
      if rethrow_errors
        self.exception_renderer = ->(e) { raise }
      end

      @interrupts = []
      @filters = []
      @global_filter = nil

      @stack_level = 0
    end

    def warnings
      @warnings ||= []
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

    def apply_global_filter(obj)
      global_filter.nil? ? obj : global_filter.call(obj)
    end

    # are there any not handled interrupts?
    def interrupt?
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

    def handle_error(e, line_number = nil)
      e = internal_error unless e.is_a?(Liquid::Error)
      e.template_name ||= template_name
      e.line_number ||= line_number
      errors.push(e)
      exception_renderer.call(e).to_s
    end

    def invoke(method, *args)
      strainer.invoke(method, *args).to_liquid
    end

    # Merge a hash of variables in the current local scope
    def merge(new_scopes)
      @scope.merge!(new_scopes)
    end

    # Pushes a new local scope on the stack, pops it at the end of the block
    #
    # Example:
    #   context.stack do
    #      context['var'] = 'hi'
    #   end
    #
    #   context['var]  #=> nil
    def stack(*variable_names)
      previous_values = {}
      variable_names.each do |variable_name|
        previous_values[variable_name] = @scope[variable_name]
      end

      @stack_level += 1
      raise StackLevelError, "Nesting too deep".freeze if @stack_level > Block::MAX_DEPTH

      begin
        yield
      ensure
        @scope.merge!(previous_values)
        @stack_level -= 1
      end
    end

    # Only allow String, Numeric, Hash, Array, Proc, Boolean or <tt>Liquid::Drop</tt>
    def []=(key, value)
      @scope[key] = value
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
      evaluate(Expression.parse(expression))
    end

    def key?(key)
      self[key] != nil
    end

    def evaluate(object)
      object.respond_to?(:evaluate) ? object.evaluate(self) : object
    end

    # Fetches an object starting at the local scope and then moving up the hierachy
    def find_variable(key, raise_on_not_found: true)
      scope = @scope if @scope.key?(key)

      if scope.nil?
        index = @environments.find_index do |e|
          variable = lookup_and_evaluate(e, key, raise_on_not_found: raise_on_not_found)
          # When lookup returned a value OR there is no value but the lookup also did not raise
          # then it is the value we are looking for.
          !variable.nil? || @strict_variables && raise_on_not_found
        end

        scope = @environments[index || -1]
      end

      variable ||= lookup_and_evaluate(scope, key, raise_on_not_found: raise_on_not_found)

      variable = variable.to_liquid
      variable.context = self if variable.respond_to?(:context=)

      variable
    end

    def lookup_and_evaluate(obj, key, raise_on_not_found: true)
      if @strict_variables && raise_on_not_found && obj.respond_to?(:key?) && !obj.key?(key)
        raise Liquid::UndefinedVariable, "undefined variable #{key}"
      end

      value = obj[key]

      if value.is_a?(Proc) && obj.respond_to?(:[]=)
        obj[key] = (value.arity == 0) ? value.call : value.call(self)
      else
        value
      end
    end

    private

    def internal_error
      # raise and catch to set backtrace and cause on exception
      raise Liquid::InternalError, 'internal'
    rescue Liquid::InternalError => exc
      exc
    end

    def squash_instance_assigns_with_environments
      @scope.each_key do |k|
        @environments.each do |env|
          if env.key?(k)
            @scope[k] = lookup_and_evaluate(env, k)
            break
          end
        end
      end
    end # squash_instance_assigns_with_environments
  end # Context
end # Liquid
