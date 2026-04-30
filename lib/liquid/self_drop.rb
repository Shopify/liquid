# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type object
  # @liquid_name self
  # @liquid_summary
  #   Provides access to variables through the current scope chain.
  # @liquid_description
  #   The `self` object resolves variables through the normal lookup hierarchy
  #   (local > file > global) without exposing filters, interrupts, errors,
  #   or other context internals. It's used when bare bracket notation
  #   (`['variable']`) needs to be replaced with an explicit variable lookup.
  #
  #   If `self` is explicitly assigned as a local variable (e.g. `{% assign self = 'value' %}`),
  #   then the local value takes precedence over the `self` object.
  # @liquid_access global
  class SelfDrop < Drop
    attr_accessor :bound_self

    def initialize(context)
      super()
      @context = context
      @bound_self = nil
    end

    def [](key)
      if @bound_self && bound_has?(key)
        bound_lookup(key)
      else
        @context.find_variable(key)
      end
    rescue UndefinedVariable
      nil
    end

    def key?(key)
      (@bound_self && bound_has?(key)) || @context.variable_defined?(key)
    end

    def to_liquid
      self
    end

    private

    def bound_has?(key)
      @bound_self.respond_to?(:key?) && @bound_self.key?(key)
    end

    def bound_lookup(key)
      return unless @bound_self.respond_to?(:[])

      @bound_self[key]
    end
  end
end
