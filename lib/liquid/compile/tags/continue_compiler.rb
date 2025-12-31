# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% continue %} tags
      #
      # Continue is implemented with Ruby's native `next` statement.
      # Since we use a while loop (not each), `next` correctly skips
      # to the next iteration, but we must increment the index first.
      class ContinueCompiler
        def self.compile(_tag, compiler, code)
          # Get the index variable from the loop context
          loop_ctx = compiler.current_loop_context
          if loop_ctx && loop_ctx[:idx_var]
            # Increment index before next, otherwise we'd infinite loop
            code.line "#{loop_ctx[:idx_var]} += 1"
          end
          code.line "next"
        end
      end
    end
  end
end
