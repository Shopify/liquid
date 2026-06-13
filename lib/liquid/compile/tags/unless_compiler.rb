# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% unless %} / {% elsif %} / {% else %} / {% endunless %} tags
      #
      # Unless is like if, but the first condition is negated
      class UnlessCompiler
        def self.compile(tag, compiler, code)
          blocks = tag.blocks

          blocks.each_with_index do |block, index|
            condition_expr = ConditionCompiler.compile(block, compiler)

            if index == 0
              # First block is negated (unless = if not)
              code.line "unless #{condition_expr}"
            elsif block.else?
              code.line "else"
            else
              # Subsequent blocks (elsif) are normal
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
