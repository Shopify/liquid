# frozen_string_literal: true

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
    attr_reader :scopes, :errors, :registers, :environments, :resource_limits, :static_registers, :static_environments
    attr_accessor :exception_renderer, :template_name, :partial, :global_filter, :strict_variables, :strict_filters

    # rubocop:disable Metrics/ParameterLists
    def self.build(environments: {}, outer_scope: {}, registers: {}, rethrow_errors: false, resource_limits: nil, static_environments: {}, &block)
      new(environments, outer_scope, registers, rethrow_errors, resource_limits, static_environments, &block)
    end

    def initialize(environments = {}, outer_scope = {}, registers = {}, rethrow_errors = false, resource_limits = nil, static_environments = {})
      @environments = [environments]
      @environments.flatten!

      @static_environments = [static_environments].flat_map(&:freeze).freeze
      @scopes              = [(outer_scope || {})]
      @registers           = registers
      @errors              = []
      @partial             = false
      @strict_variables    = false
      @resource_limits     = resource_limits || ResourceLimits.new(Template.default_resource_limits)
      @base_scope_depth    = 0
      @interrupts          = []
      @filters             = []
      @global_filter       = nil
      @disabled_tags       = {}

      self.exception_renderer = Template.default_exception_renderer
      if rethrow_errors
        self.exception_renderer = Liquid::RAISE_EXCEPTION_LAMBDA
      end

      yield self if block_given?

      # Do this last, since it could result in this object being passed to a Proc in the environment
      squash_instance_assigns_with_environments
    end
    # rubocop:enable Metrics/ParameterLists

    def warnings
      @warnings ||= []
    end

    def strainer
      @strainer ||= StrainerFactory.create(self, @filters)
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
      e.line_number   ||= line_number
      errors.push(e)
      exception_renderer.call(e).to_s
    end

    def invoke(method, *args)
      strainer.invoke(method, *args).to_liquid
    end

    # Push new local scope on the stack. use <tt>Context#stack</tt> instead
    def push(new_scope = {})
      @scopes.unshift(new_scope)
      check_overflow
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
    #   context['var']  #=> nil
    def stack(new_scope = {})
      push(new_scope)
      yield
    ensure
      pop
    end

    # Creates a new context inheriting resource limits, filters, environment etc.,
    # but with an isolated scope.
    def new_isolated_subcontext
      check_overflow

      self.class.build(
        resource_limits: resource_limits,
        static_environments: static_environments,
        registers: StaticRegisters.new(registers)
      ).tap do |subcontext|
        subcontext.base_scope_depth   = base_scope_depth + 1
        subcontext.exception_renderer = exception_renderer
        subcontext.filters  = @filters
        subcontext.strainer = nil
        subcontext.errors   = errors
        subcontext.warnings = warnings
        subcontext.disabled_tags = @disabled_tags
      end
    end

    def clear_instance_assigns
      @scopes[0] = {}
    end

    # Only allow String, Numeric, Hash, Array, Proc, Boolean or <tt>Liquid::Drop</tt>
    def []=(key, value)
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
      # This was changed from find() to find_index() because this is a very hot
      # path and find_index() is optimized in MRI to reduce object allocation
      index = @scopes.find_index { |s| s.key?(key) }

      if index
        lookup_and_evaluate(@scopes[index], key, raise_on_not_found: raise_on_not_found)
      else
        try_variable_find_in_environments(key, raise_on_not_found: raise_on_not_found)
      end
    end

    def lookup_and_evaluate(obj, key, raise_on_not_found: true)
      if @strict_variables && raise_on_not_found && obj.respond_to?(:key?) && !obj.key?(key)
        raise Liquid::UndefinedVariable, "undefined variable #{key}"
      end

      value = obj[key]

      # Skip contextualization and memoization when not found
      return if value.nil?

      value = contextualize(value)

      # Memoization layer: Proc resolution and other to_liquid computations are persisted
      if obj.respond_to?(:[]=) && !obj.frozen?
        obj[key] = value
      end

      value
    end

    def with_disabled_tags(tag_names)
      tag_names.each do |name|
        @disabled_tags[name] = @disabled_tags.fetch(name, 0) + 1
      end
      yield
    ensure
      tag_names.each do |name|
        @disabled_tags[name] -= 1
      end
    end

    def tag_disabled?(tag_name)
      @disabled_tags.fetch(tag_name, 0) > 0
    end

    # Convert input objects into liquid aware representations
    # Also assigns the context (self) through context=
    def contextualize(object)
      if object.is_a?(Proc)
        object = object.arity == 0 ? object.call : object.call(self)
      end

      # TODO: This is a block of code that needs some extra polish
      # My goal is to centralize as much as possible the contextualization/sanitization of objects being exchanged
      #   between the inputs given by the caller and templates being executed.
      # I desire for Filters to not have to worry about object conversion (eg.: StandardFilters#each)
      #   Filters implemented outside Shopify/Liquid shouldn't have to worry about this layer of internals
      #   Using a filter shouldn't create a worry for data leak and missing context
      # Running `ruby -I test` with the following implementation is successful
      # Running `rake test` which will also run tests with the liquid-c gem will lead to errors
      #   This is due to liquid-c optimizing some code paths
      #   Eg.: https://github.com/Shopify/liquid-c/blame/master/ext/liquid_c/context.h#L44-L45
      #   We would need to also add the following code in liquid-c
      # If we were to only consider Array and Hash as special use cases, this might be worth the effort
      #   Alternatively I think considering Array and Hash as the only two cases of nested objects is not quite right
      #   It might be better for extension.rb to be responsible for this. Array#to_liquid to return self is somewhat be wrong
      #   One does not prevent the other, need to make sure the generic implementation works and we can optimize over it
      # Note: Moving this logic to the different patches in extensions.rb
      #   Some changes in liquid-c is most likely required
      #   Liquid-c has early return optimization I have yet to track all code paths it relates to
      #   if (klass == rb_cString || klass == rb_cArray || klass == rb_cHash)
      #         return value;
      if object.is_a?(Array)
        object = object.map do |obj|
          contextualize(obj)
        end
      elsif object.is_a?(Hash)
        new_obj = {}
        object.map do |k, obj|
          new_obj[k] = contextualize(obj)
        end
        object = new_obj
      else
        object = object.to_liquid

        # TODO: Ideally all contextualized object would define "context=" even if they perform a noop
        # We want to ensure non-liquid objects aren't leaked in the context visible to the templates
        # Having a standard interface is a direction we can take.
        #   Alternatively, we could impose only a pre-determine array of available type is allowed
        #   Eg.: String, Integer, Symbol, Liquid::Drop not SomeCustomModelFromTheHostApplication
        # For now this might not be as pressing issue to deal with
        object.context = self if object.respond_to?(:context=)
      end

      object
    end

    protected

    attr_writer :base_scope_depth, :warnings, :errors, :strainer, :filters, :disabled_tags

    private

    attr_reader :base_scope_depth

    def try_variable_find_in_environments(key, raise_on_not_found:)
      @environments.each do |environment|
        found_variable = lookup_and_evaluate(environment, key, raise_on_not_found: raise_on_not_found)
        if !found_variable.nil? || @strict_variables && raise_on_not_found
          return found_variable
        end
      end
      @static_environments.each do |environment|
        found_variable = lookup_and_evaluate(environment, key, raise_on_not_found: raise_on_not_found)
        if !found_variable.nil? || @strict_variables && raise_on_not_found
          return found_variable
        end
      end
      nil
    end

    def check_overflow
      raise StackLevelError, "Nesting too deep" if overflow?
    end

    def overflow?
      base_scope_depth + @scopes.length > Block::MAX_DEPTH
    end

    def internal_error
      # raise and catch to set backtrace and cause on exception
      raise Liquid::InternalError, 'internal'
    rescue Liquid::InternalError => exc
      exc
    end

    def squash_instance_assigns_with_environments
      @scopes.last.each_key do |k|
        @environments.each do |env|
          if env.key?(k)
            scopes.last[k] = lookup_and_evaluate(env, k)
            break
          end
        end
      end
    end # squash_instance_assigns_with_environments
  end # Context
end # Liquid
