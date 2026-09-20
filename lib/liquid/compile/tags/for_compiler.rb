# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% for %} / {% else %} / {% endfor %} tags
      #
      # Supports:
      # - Iteration: {% for item in collection %}
      # - Limit/Offset: {% for item in collection limit:3 offset:2 %}
      # - Reversed: {% for item in collection reversed %}
      # - Forloop object: forloop.index, forloop.first, forloop.last, etc.
      # - Else block: {% for item in collection %}...{% else %}empty{% endfor %}
      class ForCompiler
        def self.compile(tag, compiler, code)
          var_name = tag.variable_name
          collection_expr = ExpressionCompiler.compile(tag.collection_name, compiler)

          # Generate unique variable names for this loop
          coll_var = compiler.generate_var_name("coll")
          idx_var = compiler.generate_var_name("idx")
          len_var = compiler.generate_var_name("len")

          # Evaluate the collection
          code.line "#{coll_var} = #{collection_expr}"
          code.line "#{coll_var} = #{coll_var}.to_a if #{coll_var}.is_a?(Range)"

          # Handle limit and offset
          if tag.from || tag.limit
            compile_slice(tag, coll_var, compiler, code)
          end

          # Handle reversed
          if tag.instance_variable_get(:@reversed)
            code.line "#{coll_var} = #{coll_var}.reverse"
          end

          # Check if collection is empty for else block
          for_block = tag.instance_variable_get(:@for_block)
          else_block = tag.instance_variable_get(:@else_block)

          if else_block
            code.line "if #{coll_var}.nil? || (#{coll_var}.respond_to?(:empty?) && #{coll_var}.empty?)"
            code.indent do
              BlockBodyCompiler.compile(else_block, compiler, code)
            end
            code.line "else"
            code.indent do
              compile_loop(tag, var_name, coll_var, idx_var, len_var, for_block, compiler, code)
            end
            code.line "end"
          else
            compile_loop(tag, var_name, coll_var, idx_var, len_var, for_block, compiler, code)
          end
        end

        private

        def self.compile_slice(tag, coll_var, compiler, code)
          from_expr = if tag.from == :continue
            # Continue from previous offset - we'd need register tracking for this
            # For now, default to 0
            "0"
          elsif tag.from
            ExpressionCompiler.compile(tag.from, compiler)
          else
            "0"
          end

          if tag.limit
            limit_expr = ExpressionCompiler.compile(tag.limit, compiler)
            code.line "#{coll_var} = (#{coll_var}.respond_to?(:slice) ? #{coll_var}.slice(__to_integer__(#{from_expr}), __to_integer__(#{limit_expr})) : #{coll_var}) || []"
          else
            code.line "#{coll_var} = (#{coll_var}.respond_to?(:drop) ? #{coll_var}.drop(__to_integer__(#{from_expr})) : #{coll_var}) || []"
          end
        end

        def self.compile_loop(tag, var_name, coll_var, idx_var, len_var, for_block, compiler, code)
          # Calculate length for forloop
          code.line "#{len_var} = #{coll_var}.respond_to?(:length) ? #{coll_var}.length : 0"
          code.line "#{idx_var} = 0"

          # The loop itself - use catch/throw for break support across nested blocks
          code.line "catch(:__loop__break__) do"
          code.indent do
            code.line "(#{coll_var}.respond_to?(:each) ? #{coll_var} : []).each do |__item__|"
            code.indent do
              # Wrap each iteration in a catch for continue support
              code.line "catch(:__loop__continue__) do"
              code.indent do
                # Set the loop variable
                code.line "assigns[#{var_name.inspect}] = __item__"

                # Build the forloop object as a hash
                code.line "assigns['forloop'] = {"
                code.indent do
                  code.line "'name' => #{tag.instance_variable_get(:@name).inspect},"
                  code.line "'length' => #{len_var},"
                  code.line "'index' => #{idx_var} + 1,"
                  code.line "'index0' => #{idx_var},"
                  code.line "'rindex' => #{len_var} - #{idx_var},"
                  code.line "'rindex0' => #{len_var} - #{idx_var} - 1,"
                  code.line "'first' => #{idx_var} == 0,"
                  code.line "'last' => #{idx_var} == #{len_var} - 1,"
                end
                code.line "}"

                # Compile the loop body
                BlockBodyCompiler.compile(for_block, compiler, code)
              end
              code.line "end"

              # Increment index (runs even after continue)
              code.line "#{idx_var} += 1"
            end
            code.line "end"
          end
          code.line "end"

          # Clean up
          code.line "assigns.delete(#{var_name.inspect})"
          code.line "assigns.delete('forloop')"
        end
      end
    end
  end
end
