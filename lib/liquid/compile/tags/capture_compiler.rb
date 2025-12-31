# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% capture var %}...{% endcapture %} tags
      #
      # Captures the output of the block into a variable
      class CaptureCompiler
        def self.compile(tag, compiler, code)
          var_name = tag.instance_variable_get(:@to)
          capture_var = compiler.generate_var_name("capture")

          # Save current output, create new buffer for capture
          code.line "#{capture_var} = __output__"
          code.line "__output__ = +''"

          # Compile the body
          code.indent do
            tag.nodelist.each do |body|
              BlockBodyCompiler.compile(body, compiler, code)
            end
          end

          # Save captured content and restore output buffer
          code.line "assigns[#{var_name.inspect}] = __output__"
          code.line "__output__ = #{capture_var}"
        end
      end
    end
  end
end
