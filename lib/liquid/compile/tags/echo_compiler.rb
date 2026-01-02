# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% echo expression %} tags
      #
      # Same as {{ expression }} but usable in {% liquid %} blocks
      class EchoCompiler
        def self.compile(tag, compiler, code)
          variable = tag.variable
          VariableCompiler.compile(variable, compiler, code)
        end
      end
    end
  end
end
