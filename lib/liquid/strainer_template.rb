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

        filter.invokable_methods.each do |method|
          filter_map[method] = filter
        end
      end

      def fetch_filter(method)
        filter_map.fetch(method)
      end

      def invokable?(method)
        filter_map.key?(method)
      end

      private

      def filter_map
        @filter_map ||= {}
      end

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
        klass = self.class.fetch_filter(method)

        instance = klass.new(@context)
        instance.public_send(method, *args)
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
