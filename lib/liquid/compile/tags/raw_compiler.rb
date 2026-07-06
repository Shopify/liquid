# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% raw %}...{% endraw %} tags
      #
      # Outputs the content as-is without parsing Liquid syntax
      class RawCompiler
        def self.compile(tag, compiler, code)
          body = tag.instance_variable_get(:@body)
          return if body.nil? || body.empty?

          code.line "__output__ << #{body.inspect}"
        end
      end
    end
  end
end
