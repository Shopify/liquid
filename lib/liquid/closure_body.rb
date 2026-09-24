# frozen_string_literal: true

module Liquid
  # Parsed syntax shared by let and closure-aware custom blocks.
  class ClosureBody
    attr_reader :body

    def initialize(body, parameters = Const::EMPTY_ARRAY)
      @body = body
      @parameters = parameters.dup.freeze
      @exports = body.nodelist.select { |node| node.is_a?(Let) && node.body_form? }.map(&:to).freeze
      freeze
    end

    def bind(context)
      Closure.new(self, @parameters, context)
    end

    def render_to_output_buffer(context, output)
      @body.render_to_output_buffer(context, output)
    end

    def exports(context)
      context.scopes.last.slice(*@exports)
    end

    def nodelist
      @body.nodelist
    end
  end
end
