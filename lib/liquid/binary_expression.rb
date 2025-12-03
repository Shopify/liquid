# frozen_string_literal: true

module Liquid
  class BinaryExpression
    attr_reader :left, :operator, :right

    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end

    def evaluate(context)
      left_value = value(left, context)
      right_value = value(@right, context)

      case operator
      when '>'
        left_value > right_value
      when '>='
        left_value >= right_value
      when '<'
        left_value < right_value
      when '<='
        left_value <= right_value
      when '=='
        left_value == right_value
      when '!=', '<>'
        left_value != right_value
      when 'contains'
        if left_value && right_value && left_value.respond_to?(:include?)
          right_value = right_value.to_s if left_value.is_a?(String)
          left_value.include?(right_value)
        else
          false
        end
      end
    end

    private

    def value(expr, context)
      Utils.to_liquid_value(context.evaluate(expr))
    end
  end
end
