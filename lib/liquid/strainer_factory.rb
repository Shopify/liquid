# frozen_string_literal: true

module Liquid
  # StrainerFactory is the factory for the filters system.
  module StrainerFactory
    extend self

    def add_global_filter(filter, world = World.default)
      Deprecations.warn("StrainerFactory.add_global_filter", "World#register_filter")
      world.register_filter(filter)
    end

    def create(context, filters = Const::EMPTY_ARRAY, world = World.default)
      Deprecations.warn("StrainerFactory.create", "StrainerFactory.create_strainer")
      world.create_strainer(context, filters)
    end

    def global_filter_names(world = World.default)
      Deprecations.warn("StrainerFactory.global_filter_names", "World#filter_method_names")
      World.strainer_template.filter_method_names
    end
  end
end
