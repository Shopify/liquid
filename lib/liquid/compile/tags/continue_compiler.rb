# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% continue %} tags
      #
      # Skips to the next iteration of a for loop
      class ContinueCompiler
        def self.compile(_tag, _compiler, code)
          # We use throw/catch in the for loop to handle continue
          code.line "throw :__loop__continue__"
        end
      end
    end
  end
end
