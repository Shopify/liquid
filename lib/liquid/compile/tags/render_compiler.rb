# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% render 'partial' %} tags
      #
      # For static template names (string literals), the partial is loaded at
      # compile time and inlined as a method.
      #
      # For dynamic template names (variables), a runtime fallback is generated
      # that calls __render_dynamic__ which must be provided by the runtime.
      class RenderCompiler
        def self.compile(tag, compiler, code)
          template_name_expr = tag.template_name_expr
          variable_name_expr = tag.variable_name_expr
          attributes = tag.attributes
          alias_name = tag.alias_name
          is_for_loop = tag.for_loop?

          # Check if the template name is a static string
          if template_name_expr.is_a?(String)
            compile_static_render(tag, template_name_expr, compiler, code)
          else
            compile_dynamic_render(tag, compiler, code)
          end
        end

        private

        def self.compile_static_render(tag, template_name, compiler, code)
          variable_name_expr = tag.variable_name_expr
          attributes = tag.attributes
          alias_name = tag.alias_name
          is_for_loop = tag.for_loop?

          # Try to load the partial at compile time
          partial_source = compiler.load_partial(template_name)

          if partial_source
            # Generate a unique method name for this partial
            method_name = compiler.register_partial(template_name, partial_source)
            context_var_name = alias_name || template_name.split('/').last

            if is_for_loop && variable_name_expr
              # Render for each item in collection
              compile_for_loop_render(tag, method_name, context_var_name, compiler, code)
            else
              # Single render
              compile_single_render(tag, method_name, context_var_name, compiler, code)
            end
          else
            # Partial not found at compile time - generate runtime fallback
            code.line "# Partial '#{template_name}' not found at compile time"
            compile_dynamic_render(tag, compiler, code)
          end
        end

        def self.compile_single_render(tag, method_name, context_var_name, compiler, code)
          variable_name_expr = tag.variable_name_expr
          attributes = tag.attributes

          # Build the inner assigns hash
          inner_assigns_var = compiler.generate_var_name("inner")
          code.line "#{inner_assigns_var} = {}"

          # Copy attributes
          attributes.each do |key, value|
            value_expr = ExpressionCompiler.compile(value, compiler)
            code.line "#{inner_assigns_var}[#{key.inspect}] = #{value_expr}"
          end

          # Set the context variable if provided
          if variable_name_expr
            var_expr = ExpressionCompiler.compile(variable_name_expr, compiler)
            code.line "#{inner_assigns_var}[#{context_var_name.inspect}] = #{var_expr}"
          end

          # Call the partial method
          code.line "__output__ << #{method_name}(#{inner_assigns_var})"
        end

        def self.compile_for_loop_render(tag, method_name, context_var_name, compiler, code)
          variable_name_expr = tag.variable_name_expr
          attributes = tag.attributes
          template_name = tag.template_name_expr

          coll_var = compiler.generate_var_name("coll")
          coll_expr = ExpressionCompiler.compile(variable_name_expr, compiler)
          code.line "#{coll_var} = #{coll_expr}"

          code.line "if #{coll_var}.respond_to?(:each) && #{coll_var}.respond_to?(:count)"
          code.indent do
            len_var = compiler.generate_var_name("len")
            idx_var = compiler.generate_var_name("idx")
            code.line "#{len_var} = #{coll_var}.count"
            code.line "#{idx_var} = 0"

            code.line "#{coll_var}.each do |__item__|"
            code.indent do
              inner_assigns_var = compiler.generate_var_name("inner")
              code.line "#{inner_assigns_var} = {}"

              # Copy attributes
              attributes.each do |key, value|
                value_expr = ExpressionCompiler.compile(value, compiler)
                code.line "#{inner_assigns_var}[#{key.inspect}] = #{value_expr}"
              end

              # Set the context variable
              code.line "#{inner_assigns_var}[#{context_var_name.inspect}] = __item__"

              # Set forloop
              code.line "#{inner_assigns_var}['forloop'] = {"
              code.indent do
                code.line "'name' => #{template_name.inspect},"
                code.line "'length' => #{len_var},"
                code.line "'index' => #{idx_var} + 1,"
                code.line "'index0' => #{idx_var},"
                code.line "'rindex' => #{len_var} - #{idx_var},"
                code.line "'rindex0' => #{len_var} - #{idx_var} - 1,"
                code.line "'first' => #{idx_var} == 0,"
                code.line "'last' => #{idx_var} == #{len_var} - 1,"
              end
              code.line "}"

              # Call the partial method
              code.line "__output__ << #{method_name}(#{inner_assigns_var})"

              code.line "#{idx_var} += 1"
            end
            code.line "end"
          end
          code.line "else"
          code.indent do
            # Single render if not a collection
            compile_single_render(tag, method_name, context_var_name, compiler, code)
          end
          code.line "end"
        end

        def self.compile_dynamic_render(tag, compiler, code)
          template_name_expr = tag.template_name_expr
          variable_name_expr = tag.variable_name_expr
          attributes = tag.attributes
          alias_name = tag.alias_name
          is_for_loop = tag.for_loop?

          name_expr = ExpressionCompiler.compile(template_name_expr, compiler)

          # Build attributes hash
          attrs_var = compiler.generate_var_name("attrs")
          code.line "#{attrs_var} = {}"
          attributes.each do |key, value|
            value_expr = ExpressionCompiler.compile(value, compiler)
            code.line "#{attrs_var}[#{key.inspect}] = #{value_expr}"
          end

          var_expr = variable_name_expr ? ExpressionCompiler.compile(variable_name_expr, compiler) : "nil"
          alias_expr = alias_name ? alias_name.inspect : "nil"

          # Call the runtime dynamic render method
          code.line "if defined?(__render_dynamic__)"
          code.indent do
            code.line "__output__ << __render_dynamic__(#{name_expr}, #{var_expr}, #{attrs_var}, #{alias_expr}, #{is_for_loop})"
          end
          code.line "else"
          code.indent do
            code.line "raise RuntimeError, 'Dynamic render requires __render_dynamic__ method: ' + #{name_expr}.inspect"
          end
          code.line "end"
        end
      end
    end
  end
end
