# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% tablerow %} tags
      #
      # Creates HTML table rows from a collection
      class TableRowCompiler
        def self.compile(tag, compiler, code)
          var_name = tag.variable_name
          collection_expr = ExpressionCompiler.compile(tag.collection_name, compiler)

          # Generate unique variable names
          coll_var = compiler.generate_var_name("coll")
          idx_var = compiler.generate_var_name("idx")
          len_var = compiler.generate_var_name("len")
          cols_var = compiler.generate_var_name("cols")
          row_var = compiler.generate_var_name("row")
          col_var = compiler.generate_var_name("col")

          # Get the columns parameter
          cols = tag.instance_variable_get(:@cols)
          cols_expr = cols ? ExpressionCompiler.compile(cols, compiler) : "nil"

          # Evaluate the collection
          code.line "#{coll_var} = #{collection_expr}"
          code.line "#{coll_var} = #{coll_var}.to_a if #{coll_var}.is_a?(Range)"

          # Handle limit and offset
          limit = tag.instance_variable_get(:@limit)
          offset = tag.instance_variable_get(:@offset)
          if offset || limit
            if offset
              offset_expr = ExpressionCompiler.compile(offset, compiler)
              if limit
                limit_expr = ExpressionCompiler.compile(limit, compiler)
                code.line "#{coll_var} = #{coll_var}.slice(__to_integer__(#{offset_expr}), __to_integer__(#{limit_expr})) || []"
              else
                code.line "#{coll_var} = #{coll_var}.drop(__to_integer__(#{offset_expr}))"
              end
            elsif limit
              limit_expr = ExpressionCompiler.compile(limit, compiler)
              code.line "#{coll_var} = #{coll_var}.first(__to_integer__(#{limit_expr}))"
            end
          end

          # Setup loop variables
          code.line "#{len_var} = #{coll_var}.respond_to?(:length) ? #{coll_var}.length : 0"
          code.line "#{cols_var} = #{cols_expr} || #{len_var}"
          code.line "#{idx_var} = 0"
          code.line "#{row_var} = 1"
          code.line "#{col_var} = 0"

          body = tag.instance_variable_get(:@body)

          # The loop
          code.line "(#{coll_var}.respond_to?(:each) ? #{coll_var} : []).each do |__item__|"
          code.indent do
            # Start new row if needed
            code.line "if #{col_var} == 0"
            code.indent do
              code.line "__output__ << \"<tr class=\\\"row\#{#{row_var}}\\\">\""
            end
            code.line "end"
            code.line "#{col_var} += 1"

            # Output cell start
            code.line "__output__ << \"<td class=\\\"col\#{#{col_var}}\\\">\""

            # Set loop variables
            code.line "assigns[#{var_name.inspect}] = __item__"
            code.line "assigns['tablerowloop'] = {"
            code.indent do
              code.line "'length' => #{len_var},"
              code.line "'index' => #{idx_var} + 1,"
              code.line "'index0' => #{idx_var},"
              code.line "'rindex' => #{len_var} - #{idx_var},"
              code.line "'rindex0' => #{len_var} - #{idx_var} - 1,"
              code.line "'first' => #{idx_var} == 0,"
              code.line "'last' => #{idx_var} == #{len_var} - 1,"
              code.line "'col' => #{col_var},"
              code.line "'col0' => #{col_var} - 1,"
              code.line "'row' => #{row_var},"
              code.line "'col_first' => #{col_var} == 1,"
              code.line "'col_last' => #{col_var} == #{cols_var},"
            end
            code.line "}"

            # Compile the body
            BlockBodyCompiler.compile(body, compiler, code)

            # Output cell end
            code.line "__output__ << '</td>'"

            # End row if needed
            code.line "if #{col_var} == #{cols_var}"
            code.indent do
              code.line "__output__ << '</tr>'"
              code.line "#{col_var} = 0"
              code.line "#{row_var} += 1"
            end
            code.line "end"

            code.line "#{idx_var} += 1"
          end
          code.line "end"

          # Close any open row
          code.line "if #{col_var} > 0"
          code.indent do
            code.line "__output__ << '</tr>'"
          end
          code.line "end"

          # Clean up
          code.line "assigns.delete(#{var_name.inspect})"
          code.line "assigns.delete('tablerowloop')"
        end
      end
    end
  end
end
