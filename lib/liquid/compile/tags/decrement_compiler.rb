# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% decrement var %} tags
      #
      # Decrements a counter and outputs its value.
      # Uses a separate namespace from regular assigns (shares with increment).
      class DecrementCompiler
        def self.compile(tag, compiler, code)
          var_name = tag.variable_name

          # Initialize counter storage if needed
          code.line "assigns[:__counters__] ||= {}"

          # Get current value (default 0), decrement it, output, then store
          dec_var = compiler.generate_var_name("dec")
          code.line "#{dec_var} = (assigns[:__counters__][#{var_name.inspect}] || 0) - 1"
          code.line "assigns[:__counters__][#{var_name.inspect}] = #{dec_var}"
          code.line "__output__ << #{dec_var}.to_s"
        end
      end
    end
  end
end
