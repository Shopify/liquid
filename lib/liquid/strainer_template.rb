# frozen_string_literal: true

require 'set'

module Liquid
  # StrainerTemplate is the computed class for the filters system.
  # New filters are mixed into the strainer class which is then instantiated for each liquid template render run.
  #
  # The Strainer only allows method calls defined in filters given to it via StrainerFactory.add_global_filter,
  # Context#add_filters or Template.register_filter
  class StrainerTemplate
    def initialize(context)
      @context = context
    end

    class << self
      def add_filter(filter)
        return if include?(filter)

        invokable_non_public_methods = (filter.private_instance_methods + filter.protected_instance_methods).select { |m| invokable?(m) }
        if invokable_non_public_methods.any?
          raise MethodOverrideError, "Filter overrides registered public methods as non public: #{invokable_non_public_methods.join(', ')}"
        end

        include(filter)

        filter_methods.merge(filter.public_instance_methods.map(&:to_s))
      end

      def invokable?(method)
        filter_methods.include?(method.to_s)
      end

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@filter_methods, @filter_methods.dup)
      end

      def filter_method_names
        filter_methods.map(&:to_s).to_a
      end

      private

      def filter_methods
        @filter_methods ||= Set.new
      end
    end

    def invoke(method, *args)
      if self.class.invokable?(method)
        send(method, *args)
      elsif @context.strict_filters
        raise Liquid::UndefinedFilter, "undefined filter #{method}"
      else
        args.first
      end
    rescue ::ArgumentError => e
      raise Liquid::ArgumentError, e.message, e.backtrace
    end

    # Arity-specialized filter invocation.
    # Avoids *args splat allocation for the common 0-arg and 1-arg cases.
    # `invoke` (general case) still uses *args for 2+ extra arguments.
    {
      invoke_single: ['input'],
      invoke_two: ['input', 'arg1'],
    }.each do |method_name, params|
      all_params = (["method"] + params).join(", ")
      send_params = params.join(", ")
      # __LINE__ + 1 is a parse-time constant; both generated methods will report
      # the same file:line in backtraces. The method name in the trace distinguishes them.
      module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
        def #{method_name}(#{all_params})
          if self.class.invokable?(method)
            send(method, #{send_params})
          elsif @context.strict_filters
            raise Liquid::UndefinedFilter, "undefined filter \#{method}"
          else
            input
          end
        rescue ::ArgumentError => e
          raise Liquid::ArgumentError, e.message, e.backtrace
        end
      RUBY
    end
  end
end
