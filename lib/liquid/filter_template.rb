# frozen_string_literal: true

require 'set'

module Liquid
  # FilterTemplate is the computed class for the filters system.
  #
  # Historically Liquid used to include filters as Module to the context strainer.
  # This lead to the absence of sandbox between filters (one filter could override private methods of another filter).
  #
  # With the implementation of Liquid::Filter, it is now possible for the modules from legacy code to be automatically
  #   wrapped into a Liquid::Filter generated class.
  #
  # This should not be considered as the base behaviour, it is preferred to create filters going forward directly as
  #   classes that are child of Liquid::Filter.
  class FilterTemplate < Filter
    class << self
      def include(mod)
        super

        @init_module = mod
      end

      # Override of the `invokable_methods`.
      # We can't rely on the parent logic as some modules might have been defining methods that shadow Class methods.
      #
      # Eg.:
      # mod = Liquid::StandardFilters
      # filter = Class.new(FilterTemplate)
      # filter.include(mod)
      # mod.public_instance_methods - (filter.public_instance_methods - Class.public_instance_methods)
      # => [:prepend]
      def invokable_methods
        whitelist = @init_module.public_instance_methods

        @invokable_methods ||= Set.new(whitelist.map(&:to_s))
      end
    end
  end
end
