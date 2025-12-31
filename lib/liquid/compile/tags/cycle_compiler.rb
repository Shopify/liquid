# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% cycle 'a', 'b', 'c' %} tags
      #
      # Cycles through a list of values, outputting the next one each iteration
      class CycleCompiler
        def self.compile(tag, compiler, code)
          variables = tag.variables
          name_expr = ExpressionCompiler.compile(tag.instance_variable_get(:@name), compiler)
          is_named = tag.named?

          cycle_var = compiler.generate_var_name("cycle")
          key_var = compiler.generate_var_name("cycle_key")

          # Initialize cycle storage if needed
          code.line "assigns[:__cycle__] ||= {}"

          # Get the cycle key
          if is_named
            code.line "#{key_var} = #{name_expr}"
          else
            code.line "#{key_var} = #{variables.object_id}"
          end

          # Get current index
          code.line "#{cycle_var} = assigns[:__cycle__][#{key_var}].to_i"

          # Get the value at current index
          code.line "case #{cycle_var} % #{variables.size}"
          variables.each_with_index do |var, idx|
            var_expr = ExpressionCompiler.compile(var, compiler)
            code.line "when #{idx} then __output__ << LR.to_s(#{var_expr})"
          end
          code.line "end"

          # Increment counter
          code.line "assigns[:__cycle__][#{key_var}] = #{cycle_var} + 1"
        end
      end
    end
  end
end
