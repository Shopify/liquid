# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% assign var = expression %} tags
      class AssignCompiler
        def self.compile(tag, compiler, code)
          var_name = tag.to
          # Use VariableCompiler to get the expression with filters applied
          value_expr = VariableCompiler.compile_to_expression(tag.from, compiler)

          # Store in the assigns hash
          code.line "assigns[#{var_name.inspect}] = #{value_expr}"
        end
      end
    end
  end
end
