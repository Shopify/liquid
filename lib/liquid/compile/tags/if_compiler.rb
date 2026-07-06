# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% if %} / {% elsif %} / {% else %} / {% endif %} tags
      class IfCompiler
        def self.compile(tag, compiler, code)
          blocks = tag.blocks

          blocks.each_with_index do |block, index|
            condition_expr = ConditionCompiler.compile(block, compiler)

            if index == 0
              code.line "if #{condition_expr}"
            elsif block.else?
              code.line "else"
            else
              code.line "elsif #{condition_expr}"
            end

            code.indent do
              if block.attachment
                BlockBodyCompiler.compile(block.attachment, compiler, code)
              end
            end
          end

          code.line "end"
        end
      end
    end
  end
end
