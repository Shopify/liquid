# frozen_string_literal: true

module Liquid
  # An array written in a template, such as `[1, product.title, [a, b]]`.
  class ArrayLiteral
    attr_reader :elements

    def initialize(elements)
      @elements = elements.freeze
    end

    # Returns a new Array on every evaluation, so a change to one result
    # never reaches another render or a later evaluation in the same render.
    def evaluate(context)
      @elements.map { |element| context.evaluate(element) }
    end

    def ==(other)
      self.class == other.class && elements == other.elements
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        @node.elements
      end
    end
  end
end
