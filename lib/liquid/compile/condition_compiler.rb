# frozen_string_literal: true

module Liquid
  module Compile
    # ConditionCompiler compiles Liquid conditions to Ruby boolean expressions.
    #
    # Handles:
    # - Simple truthiness: {% if variable %}
    # - Comparisons: {% if a == b %}, {% if a > b %}
    # - Logical operators: {% if a and b %}, {% if a or b %}
    # - Special checks: {% if a == blank %}, {% if a == empty %}
    class ConditionCompiler
      # Operator mappings from Liquid to Ruby
      OPERATORS = {
        '==' => '==',
        '!=' => '!=',
        '<>' => '!=',
        '<' => '<',
        '>' => '>',
        '<=' => '<=',
        '>=' => '>=',
        'contains' => :contains,
      }.freeze

      # Compile a Condition to a Ruby boolean expression
      # @param condition [Liquid::Condition] The condition
      # @param compiler [RubyCompiler] The main compiler instance
      # @return [String] Ruby code expression that evaluates to true/false
      def self.compile(condition, compiler)
        if condition.is_a?(ElseCondition)
          return "true"
        end

        compile_condition_chain(condition, compiler)
      end

      private

      def self.compile_condition_chain(condition, compiler)
        # Compile the current condition
        current = compile_single_condition(condition, compiler)

        # Check for chained conditions (and/or)
        if condition.child_condition
          child = compile_condition_chain(condition.child_condition, compiler)
          child_relation = condition.send(:child_relation)

          case child_relation
          when :and
            "(#{current} && #{child})"
          when :or
            "(#{current} || #{child})"
          else
            current
          end
        else
          current
        end
      end

      def self.compile_single_condition(condition, compiler)
        left = condition.left
        op = condition.operator
        right = condition.right

        # If no operator, just check truthiness
        if op.nil?
          left_expr = ExpressionCompiler.compile(left, compiler)
          return "__truthy__(#{left_expr})"
        end

        # Compile left and right expressions
        left_expr = compile_condition_value(left, compiler)
        right_expr = compile_condition_value(right, compiler)

        # Handle special operators
        case OPERATORS[op]
        when :contains
          compile_contains(left_expr, right_expr, compiler)
        when '=='
          compile_equality(left, right, left_expr, right_expr, compiler)
        when '!='
          "!(#{compile_equality(left, right, left_expr, right_expr, compiler)})"
        else
          # Standard comparison
          ruby_op = OPERATORS[op] || op
          "(#{left_expr} #{ruby_op} #{right_expr} rescue false)"
        end
      end

      def self.compile_condition_value(expr, compiler)
        if expr.is_a?(Condition::MethodLiteral)
          # For blank/empty checks, we return a special marker
          # The equality handler will deal with this
          ":__method_literal_#{expr.method_name}__"
        else
          ExpressionCompiler.compile(expr, compiler)
        end
      end

      def self.compile_equality(left, right, left_expr, right_expr, compiler)
        # Handle blank/empty method literals
        if left.is_a?(Condition::MethodLiteral)
          method_name = left.method_name
          "(#{right_expr}.respond_to?(:#{method_name}) ? #{right_expr}.#{method_name} : nil)"
        elsif right.is_a?(Condition::MethodLiteral)
          method_name = right.method_name
          "(#{left_expr}.respond_to?(:#{method_name}) ? #{left_expr}.#{method_name} : nil)"
        else
          "(#{left_expr} == #{right_expr})"
        end
      end

      def self.compile_contains(left_expr, right_expr, compiler)
        # The contains operator checks if left includes right
        # For strings, right is converted to a string
        "(lambda { |left, right| " \
          "return false if left.nil? || right.nil? || !left.respond_to?(:include?); " \
          "right = right.to_s if left.is_a?(String); " \
          "left.include?(right) rescue false " \
          "}.call(#{left_expr}, #{right_expr}))"
      end
    end
  end
end
