# frozen_string_literal: true

module Liquid
  # StrainerFactory is the factory for the filters system.
  module StrainerFactory
    extend self

    def add_global_filter(filter)
      strainer_class_cache.clear
      global_filters << filter
    end

    def create(context, filters = [])
      strainer_from_cache(filters).new(context)
    end

    private

    def global_filters
      @global_filters ||= []
    end

    def strainer_from_cache(filters)
      strainer_class_cache[filters] ||= begin
        klass = Class.new(StrainerTemplate)
        global_filters.each { |f| klass.add_filter(f) }
        filters.each { |f| klass.add_filter(f) }
        klass
      end
    end

    def strainer_class_cache
      @strainer_class_cache ||= {}
    end
  end
end
