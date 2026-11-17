# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% increment var %} tags
      #
      # Outputs the current counter value, then increments it.
      # Uses a separate namespace from regular assigns (shares with decrement).
      class IncrementCompiler
        def self.compile(tag, compiler, code)
          var_name = tag.variable_name

          # Initialize counter storage if needed
          code.line "assigns[:__counters__] ||= {}"

          # Get current value (default 0), output it, then increment
          inc_var = compiler.generate_var_name("inc")
          code.line "#{inc_var} = assigns[:__counters__][#{var_name.inspect}] || 0"
          code.line "__output__ << #{inc_var}.to_s"
          code.line "assigns[:__counters__][#{var_name.inspect}] = #{inc_var} + 1"
        end
      end
    end
  end
end
