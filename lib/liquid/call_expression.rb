# frozen_string_literal: true

module Liquid
  class CallExpression
    attr_reader :target, :arguments

    def initialize(target, arguments)
      @target = target.freeze
      @arguments = arguments.freeze
      freeze
    end

    def evaluate(context)
      context.resource_limits.with_capture do
        render_to_output_buffer(context, +'')
      end
    end

    def render_to_output_buffer(context, output)
      closure = context.evaluate(@target)
      raise Liquid::ArgumentError, "Expected a Liquid closure" unless closure.is_a?(Closure)

      arguments = @arguments.map { |argument| context.evaluate(argument) }
      closure.render_to_output_buffer(context, output, arguments)
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.target] + @node.arguments
      end
    end
  end
end
