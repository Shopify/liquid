# frozen_string_literal: true

module Liquid
  # A render-time value. Captures retain binding hashes, not copies of their values.
  class Closure
    def initialize(body, parameters, context)
      @body = body
      @parameters = parameters
      @scopes = context.scopes.dup
      @environments = context.environments.dup
      @static_environments = context.static_environments
    end

    # Render into the supplied buffer and return direct-child body-form let bindings.
    def invoke(context, arguments = Const::EMPTY_ARRAY, output: +'')
      invocation = render_invocation(context, arguments, output)
      @body.exports(invocation)
    end

    def render_to_output_buffer(context, output, arguments = Const::EMPTY_ARRAY)
      render_invocation(context, arguments, output)
      output
    end

    def to_liquid
      self
    end

    def to_s
      ''
    end

    private

    def render_invocation(context, arguments, output)
      unless arguments.length == @parameters.length
        raise Liquid::ArgumentError, "Expected #{@parameters.length} closure arguments, got #{arguments.length}"
      end

      invocation = context.new_closure_subcontext(@scopes, @environments, @static_environments)
      @parameters.each_with_index { |name, index| invocation[name] = arguments[index] }
      @body.render_to_output_buffer(invocation, output)
      invocation
    end

    # @api private
    class CapturedBindings
      def initialize(scopes, environments, context)
        @scopes = scopes
        @environments = environments
        @context = context
        @locals = {}
      end

      def key?(name)
        local_key?(name) || @environments.any? { |environment| environment.key?(name) }
      end

      def local_key?(name)
        @locals.key?(name) || @scopes.any? { |scope| scope.key?(name) } ||
          @environments.any? { |environment| environment.is_a?(CapturedBindings) && environment.local_key?(name) }
      end

      def []=(name, value)
        @locals[name] = value
      end

      def [](name)
        find_variable(name, @context, raise_on_not_found: false)
      end

      def find_variable(name, context, raise_on_not_found: true)
        return context.lookup_and_evaluate(@locals, name, raise_on_not_found: raise_on_not_found) if @locals.key?(name)

        scope = @scopes.find { |candidate| candidate.key?(name) }
        return context.lookup_and_evaluate(scope, name, raise_on_not_found: raise_on_not_found) if scope

        find_in_environments(name, context, raise_on_not_found: raise_on_not_found)
      end

      private

      def find_in_environments(name, context, raise_on_not_found:)
        @environments.each do |environment|
          if environment.is_a?(CapturedBindings)
            return environment.find_variable(name, context, raise_on_not_found: raise_on_not_found)
          end

          value = context.lookup_and_evaluate(environment, name, raise_on_not_found: raise_on_not_found)
          return value if !value.nil? || context.strict_variables && raise_on_not_found
        end
        nil
      end
    end
  end
end
