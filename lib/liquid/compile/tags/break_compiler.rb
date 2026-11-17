# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% break %} tags
      #
      # Breaks out of a for loop
      class BreakCompiler
        def self.compile(_tag, _compiler, code)
          # We use throw/catch in the for loop to handle break
          # This allows break to work from nested blocks
          code.line "throw :__loop__break__"
        end
      end
    end
  end
end
