# frozen_string_literal: true

module Liquid
  module Compile
    # ExpressionCompiler compiles Liquid expressions to Ruby code.
    #
    # Expressions include:
    # - Literals: nil, true, false, strings, numbers
    # - Variable lookups: foo, foo.bar, foo[0], foo["key"]
    # - Ranges: (1..10), (start..end)
    class ExpressionCompiler
      # Compile an expression to a Ruby code string
      # @param expr [Object] The parsed expression
      # @param compiler [RubyCompiler] The main compiler instance
      # @return [String] Ruby code that evaluates to the expression value
      def self.compile(expr, compiler)
        case expr
        when nil
          "nil"
        when true
          "true"
        when false
          "false"
        when String
          expr.inspect
        when Integer, Float
          expr.inspect
        when Range
          "(#{expr.begin.inspect}..#{expr.end.inspect})"
        when VariableLookup
          compile_variable_lookup(expr, compiler)
        when RangeLookup
          compile_range_lookup(expr, compiler)
        when Condition::MethodLiteral
          # Handle blank/empty method literals
          compile_method_literal(expr, compiler)
        else
          raise CompileError, "Unknown expression type: #{expr.class} (#{expr.inspect})"
        end
      end

      # Compile a variable lookup expression
      # @param lookup [VariableLookup] The variable lookup
      # @param compiler [RubyCompiler] The main compiler instance
      # @return [String] Ruby code that evaluates to the variable value
      def self.compile_variable_lookup(lookup, compiler)
        # Start with the base variable
        name = lookup.name

        # Handle dynamic name (expression in brackets)
        base = if name.is_a?(VariableLookup) || name.is_a?(RangeLookup)
          # Dynamic name like [expr].foo
          "assigns[#{compile(name, compiler)}]"
        elsif name.is_a?(String)
          "assigns[#{name.inspect}]"
        elsif name.is_a?(Integer)
          "assigns[#{name.inspect}]"
        else
          compile(name, compiler)
        end

        # Apply each lookup in the chain
        lookup.lookups.each_with_index do |key, index|
          if key.is_a?(VariableLookup) || key.is_a?(RangeLookup)
            # Dynamic key like foo[expr]
            base = "__lookup__.call(#{base}, #{compile(key, compiler)})"
          elsif key.is_a?(Integer)
            # Numeric index like foo[0]
            base = "__lookup__.call(#{base}, #{key})"
          elsif key.is_a?(String)
            # Always use __lookup__ which tries key access first,
            # then falls back to method call for command methods (first, last, size)
            base = "__lookup__.call(#{base}, #{key.inspect})"
          else
            base = "__lookup__.call(#{base}, #{compile(key, compiler)})"
          end
        end

        base
      end

      # Compile a range lookup expression
      # @param range [RangeLookup] The range lookup
      # @param compiler [RubyCompiler] The main compiler instance
      # @return [String] Ruby code that evaluates to the range
      def self.compile_range_lookup(range, compiler)
        start_expr = compile(range.start_obj, compiler)
        end_expr = compile(range.end_obj, compiler)

        # Convert to integers and create range
        "(__to_integer__(#{start_expr})...__to_integer__(#{end_expr})).to_a"
      end

      # Compile a method literal (blank/empty)
      def self.compile_method_literal(literal, compiler)
        # These are used in conditions like `if foo == blank`
        # They represent special method calls
        literal.to_s.inspect
      end

      # Compile an expression for use in a condition
      # @param expr [Object] The expression
      # @param compiler [RubyCompiler] The main compiler
      # @return [String] Ruby code for the condition value
      def self.compile_for_condition(expr, compiler)
        if expr.is_a?(Condition::MethodLiteral)
          # Return the method name symbol for special handling
          ":#{expr.method_name}"
        else
          compile(expr, compiler)
        end
      end
    end
  end
end
