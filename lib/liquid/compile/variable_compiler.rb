# frozen_string_literal: true

module Liquid
  module Compile
    # VariableCompiler compiles Liquid variable expressions ({{ ... }}) to Ruby code.
    #
    # A Variable consists of:
    # - A name expression (the value to output)
    # - Zero or more filters to apply
    class VariableCompiler
      # Compile a Variable node and append the result to the output buffer
      # @param variable [Liquid::Variable] The variable node
      # @param compiler [RubyCompiler] The main compiler instance
      # @param code [CodeGenerator] The code generator
      def self.compile(variable, compiler, code)
        value_expr = compile_to_expression(variable, compiler)
        code.line "__output__ << LR.output(#{value_expr})"
      end

      # Compile a Variable node to a Ruby expression (without output)
      # @param variable [Liquid::Variable] The variable node
      # @param compiler [RubyCompiler] The main compiler instance
      # @return [String] Ruby code expression
      def self.compile_to_expression(variable, compiler)
        # Compile the base name expression
        base_expr = ExpressionCompiler.compile(variable.name, compiler)

        # Apply filters if any
        if variable.filters && !variable.filters.empty?
          FilterCompiler.compile(base_expr, variable.filters, compiler)
        else
          base_expr
        end
      end
    end
  end
end
