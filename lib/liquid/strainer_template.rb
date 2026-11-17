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
      result = if self.class.invokable?(method)
        send(method, *args)
      elsif @context.strict_filters
        raise Liquid::UndefinedFilter, "undefined filter #{method}"
      else
        args.first
      end

      # See Drop#invoke_drop: the context is not guaranteed to be a
      # Liquid::Context, and instrumentation must not raise.
      if defined?(TemplateRecorder) && TemplateRecorder::HOOKS_ENABLED && @context.respond_to?(:registers)
        recorder = @context.registers[TemplateRecorder::REGISTER_KEY]
      end
      recorder&.emit_filter_call(method, args.first, args.drop(1), result)
      result
    rescue ::ArgumentError => e
      raise Liquid::ArgumentError, e.message, e.backtrace
    end
  end
end
