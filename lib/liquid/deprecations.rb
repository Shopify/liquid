# frozen_string_literal: true

require "set"

module Liquid
  class Deprecations
    class << self
      attr_accessor :warned

      Deprecations.warned = Set.new

      def warn(name, alternative)
        return if warned.include?(name)

        warned << name

        caller_location = caller_locations(2, 1).first
        Warning.warn("[DEPRECATION] #{name} is deprecated. Use #{alternative} instead. Called from #{caller_location}\n")
      end
    end
  end
end
