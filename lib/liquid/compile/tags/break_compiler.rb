# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% break %} tags
      #
      # Break is implemented with a flag variable that's checked in the while condition.
      # This avoids catch/throw overhead entirely.
      #
      # Generated code sets the break flag and uses `next` to exit the current iteration.
      # The while loop condition checks the flag and exits if set.
      class BreakCompiler
        def self.compile(_tag, compiler, code)
          loop_ctx = compiler.current_loop_context
          if loop_ctx && loop_ctx[:break_var]
            # Set the break flag and exit this iteration
            code.line "#{loop_ctx[:break_var]} = true"
            code.line "next"
          else
            # Fallback: shouldn't happen if contains_tag? works correctly
            code.line "break"
          end
        end
      end
    end
  end
end
