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

        # Check for forloop property inlining
        if name == 'forloop' && lookup.lookups.length == 1
          loop_ctx = compiler.current_loop_context
          if loop_ctx && loop_ctx[:idx_var]
            inlined = compile_forloop_property(lookup.lookups.first, loop_ctx)
            return inlined if inlined
          end
        end

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
            base = "LR.lookup(#{base}, #{compile(key, compiler)}, __context__)"
          elsif key.is_a?(Integer)
            # Numeric index like foo[0]
            base = "LR.lookup(#{base}, #{key}, __context__)"
          elsif key.is_a?(String)
            # Always use LR.lookup which tries key access first,
            # then falls back to method call for command methods (first, last, size)
            base = "LR.lookup(#{base}, #{key.inspect}, __context__)"
          else
            base = "LR.lookup(#{base}, #{compile(key, compiler)}, __context__)"
          end
        end

        base
      end

      # Inline forloop property access to avoid hash allocation
      # @param prop [String] Property name (index, index0, first, last, etc.)
      # @param loop_ctx [Hash] Loop context with idx_var, len_var, loop_name
      # @return [String, nil] Inlined Ruby code or nil if can't inline
      def self.compile_forloop_property(prop, loop_ctx)
        idx = loop_ctx[:idx_var]
        len = loop_ctx[:len_var]
        name = loop_ctx[:loop_name]

        case prop
        when 'index'
          "(#{idx} + 1)"
        when 'index0'
          idx
        when 'rindex'
          "(#{len} - #{idx})"
        when 'rindex0'
          "(#{len} - #{idx} - 1)"
        when 'first'
          "(#{idx} == 0)"
        when 'last'
          "(#{idx} == #{len} - 1)"
        when 'length'
          len
        when 'name'
          name ? name.inspect : "nil"
        else
          nil # Unknown property, fall back to hash lookup
        end
      end

      # Compile a range lookup expression
      # @param range [RangeLookup] The range lookup
      # @param compiler [RubyCompiler] The main compiler instance
      # @return [String] Ruby code that evaluates to the range
      def self.compile_range_lookup(range, compiler)
        start_expr = compile(range.start_obj, compiler)
        end_expr = compile(range.end_obj, compiler)

        # Convert to integers and create range
        "(LR.to_integer(#{start_expr})...LR.to_integer(#{end_expr})).to_a"
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
