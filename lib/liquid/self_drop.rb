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
    def initialize(self_context)
      super()
      @self_context = self_context
    end

    def [](key)
      @self_context.find_variable(key)
    rescue UndefinedVariable
      nil
    end

    def key?(key)
      @self_context.variable_defined?(key)
    end

    def to_liquid
      self
    end

    def ==(other)
      other.is_a?(SelfDrop) && other.self_context.equal?(@self_context)
    end

    alias_method :eql?, :==

    def hash
      @self_context.object_id.hash
    end

    protected

    attr_reader :self_context

    undef context=
  end
end
