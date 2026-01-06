# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% ifchanged %}...{% endifchanged %} tags
      #
      # Only outputs if the content has changed since last render
      class IfchangedCompiler
        def self.compile(tag, compiler, code)
          capture_var = compiler.generate_var_name("ifchanged")

          # Capture the block output
          code.line "#{capture_var} = +''"
          code.line "begin"
          code.indent do
            code.line "__saved_output__ = __output__"
            code.line "__output__ = #{capture_var}"

            # Compile the body
            tag.nodelist.each do |body|
              BlockBodyCompiler.compile(body, compiler, code)
            end

            code.line "__output__ = __saved_output__"
          end
          code.line "end"

          # Only output if changed
          code.line "if #{capture_var} != assigns[:__ifchanged__]"
          code.indent do
            code.line "assigns[:__ifchanged__] = #{capture_var}"
            code.line "__output__ << #{capture_var}"
          end
          code.line "end"
        end
      end
    end
  end
end
