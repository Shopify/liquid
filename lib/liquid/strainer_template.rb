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
      def add_filter(mod)
        filter = if mod.is_a?(Class) && mod.ancestors.include?(Liquid::Filter)
          mod
        elsif mod.instance_of?(Module)
          convert_mod_to_filter(mod)
        else
          raise(ArgumentError, "wrong argument type Proc (expected Liquid::Filter)")
        end

        instance = filter.new

        filter.invokable_methods.each do |method|
          filter_instances[method] = instance
        end
      end

      def invokable?(method)
        filter_instances.key?(method)
      end

      def invoke(method, context, *args)
        instance = filter_instances.fetch(method)
        instance.context = context
        instance.public_send(method, *args)
      end

      private

      def filter_instances
        @filter_instances ||= {}
      end

      # Caching here is most likely not required anymore since we cache instances and there is only one instance per filter class.
      def convert_mod_to_filter(mod)
        @filter_classes ||= {}
        @filter_classes[mod] ||= begin
          klass = Class.new(FilterTemplate)
          klass.include(mod)
          klass
        end
      end

      def filter_class_by_methods
        @filter_class_by_methods ||= {}
      end
    end

    def invoke(method, *args)
      if self.class.invokable?(method)
        self.class.invoke(method, @context, *args)
      elsif @context.strict_filters
        raise(Liquid::UndefinedFilter, "undefined filter #{method}")
      else
        args.first
      end
    rescue ::ArgumentError => e
      raise Liquid::ArgumentError, e.message, e.backtrace
    end

    private

    attr_reader :context
  end
end
