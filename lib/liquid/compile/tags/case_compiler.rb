# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% case %} / {% when %} / {% else %} / {% endcase %} tags
      class CaseCompiler
        def self.compile(tag, compiler, code)
          # Compile the case expression and store it in a variable
          # to avoid evaluating it multiple times
          case_var = compiler.generate_var_name("case")
          case_expr = ExpressionCompiler.compile(tag.left, compiler)
          code.line "#{case_var} = #{case_expr}"

          blocks = tag.blocks
          is_first = true
          has_else = false

          blocks.each do |block|
            if block.else?
              has_else = true
              code.line "else"
            else
              # 'when' condition - compare case expression with the when value
              when_expr = ExpressionCompiler.compile(block.right, compiler)

              if is_first
                code.line "if #{case_var} == #{when_expr}"
                is_first = false
              else
                code.line "elsif #{case_var} == #{when_expr}"
              end
            end

            code.indent do
              if block.attachment
                BlockBodyCompiler.compile(block.attachment, compiler, code)
              end
            end
          end

          code.line "end" unless blocks.empty?
        end
      end
    end
  end
end
