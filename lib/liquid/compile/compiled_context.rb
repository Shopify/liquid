# frozen_string_literal: true

module Liquid
  module Compile
    # CompiledContext is a lightweight context-like object for compiled templates.
    #
    # It duck-types to Liquid::Context well enough for Drops to work, providing:
    # - Variable lookup via [] and find_variable
    # - strict_variables flag
    # - registers hash
    # - evaluate method for expressions
    #
    # This allows Drops to access other variables and use context features
    # while still running in compiled mode.
    class CompiledContext
      attr_reader :assigns, :registers
      attr_accessor :strict_variables, :strict_filters

      def initialize(assigns, registers: {}, strict_variables: false, strict_filters: false)
        @assigns = assigns
        @registers = registers.is_a?(Liquid::Registers) ? registers : Liquid::Registers.new(registers)
        @strict_variables = strict_variables
        @strict_filters = strict_filters
      end

      # Variable lookup - used by Drops to access other variables
      def [](key)
        @assigns[key.to_s]
      end

      # Find a variable by name
      def find_variable(key)
        result = @assigns[key.to_s]
        result = result.to_liquid if result.respond_to?(:to_liquid)
        result.context = self if result.respond_to?(:context=)
        result
      end

      # Evaluate an expression (for Drops that need to evaluate sub-expressions)
      def evaluate(expr)
        case expr
        when String, Integer, Float, TrueClass, FalseClass, NilClass
          expr
        when Liquid::VariableLookup
          expr.evaluate(self)
        else
          expr
        end
      end

      # Lookup and evaluate - handles Procs in assigns
      def lookup_and_evaluate(obj, key)
        value = obj[key]
        value = value.call(self) if value.is_a?(Proc)
        value
      end

      # Handle errors (simplified - just return message)
      def handle_error(error, _line_number = nil)
        error.message
      end

      # Check if execution should be interrupted
      def interrupt?
        false
      end

      # Stub for resource limits (no-op in compiled mode)
      def resource_limits
        @resource_limits ||= ResourceLimitStub.new
      end
    end

    # Stub for resource limits in compiled mode
    class ResourceLimitStub
      def increment_render_score(_score); end
      def increment_write_score(_output); end
      def reached?; false; end
    end
  end
end
