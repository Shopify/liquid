# frozen_string_literal: true

module Liquid
  class BinaryExpression
    attr_reader :operator
    attr_accessor :left_node, :right_node

    def initialize(left, operator, right)
      @left_node = left
      @operator = operator
      @right_node = right
    end

    def evaluate(context)
      left = value(left_node, context)
      right = value(right_node, context)

      case operator
      when '>'
        left > right if can_compare?(left, right)
      when '>='
        left >= right if can_compare?(left, right)
      when '<'
        left < right if can_compare?(left, right)
      when '<='
        left <= right if can_compare?(left, right)
      when '=='
        equal_variables(left, right)
      when '!=', '<>'
        !equal_variables(left, right)
      when 'contains'
        contains(left, right)
      else
        raise(Liquid::ArgumentError, "Unknown operator #{operator}")
      end
    rescue ::ArgumentError => e
      raise Liquid::ArgumentError, e.message
    end

    def to_s
      "(#{left_node} #{operator} #{right_node})"
    end

    private

    def value(expr, context)
      Utils.to_liquid_value(context.evaluate(expr))
    end

    def can_compare?(left, right)
      left.respond_to?(operator) && right.respond_to?(operator) && !left.is_a?(Hash) && !right.is_a?(Hash)
    end

    def contains(left, right)
      if left && right && left.respond_to?(:include?)
        right = right.to_s if left.is_a?(String)
        left.include?(right)
      else
        false
      end
    rescue Encoding::CompatibilityError
      # "✅".b.include?("✅") raises Encoding::CompatibilityError despite being materially equal
      left.b.include?(right.b)
    end

    def apply_method_literal(node, other)
      other.send(node.method_name) if other.respond_to?(node.method_name)
    end

    def equal_variables(left, right)
      return apply_method_literal(left, right) if left.is_a?(MethodLiteral)
      return apply_method_literal(right, left) if right.is_a?(MethodLiteral)

      left == right
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [
          @node.left_node,
          @node.right_node,
        ]
      end
    end
  end
end
