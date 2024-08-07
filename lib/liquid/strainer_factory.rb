# frozen_string_literal: true

module Liquid
  # StrainerFactory is the factory for the filters system.
  module StrainerFactory
    extend self

    def add_global_filter(filter, environment = Environment.default)
      Deprecations.warn("StrainerFactory.add_global_filter", "Environment#register_filter")
      environment.register_filter(filter)
    end

    def create(context, filters = Const::EMPTY_ARRAY, environment = Environment.default)
      Deprecations.warn("StrainerFactory.create", "StrainerFactory.create_strainer")
      environment.create_strainer(context, filters)
    end

    def global_filter_names(environment = Environment.default)
      Deprecations.warn("StrainerFactory.global_filter_names", "Environment#filter_method_names")
      Environment.strainer_template.filter_method_names
    end
  end
end
