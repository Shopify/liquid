# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% include 'partial' %} tags
      #
      # Include is deprecated in favor of render, but we support it for compatibility.
      # Unlike render, include shares the outer scope with the partial.
      #
      # For static template names, the partial is loaded and inlined at compile time.
      # For dynamic template names, a runtime fallback is generated.
      class IncludeCompiler
        def self.compile(tag, compiler, code)
          template_name_expr = tag.template_name_expr
          variable_name_expr = tag.variable_name_expr
          attributes = tag.attributes
          alias_name = tag.instance_variable_get(:@alias_name)

          # Check if the template name is a static string
          if template_name_expr.is_a?(String)
            compile_static_include(tag, template_name_expr, compiler, code)
          else
            compile_dynamic_include(tag, compiler, code)
          end
        end

        private

        def self.compile_static_include(tag, template_name, compiler, code)
          variable_name_expr = tag.variable_name_expr
          attributes = tag.attributes
          alias_name = tag.instance_variable_get(:@alias_name)

          # Try to load the partial at compile time
          partial_source = compiler.load_partial(template_name)

          if partial_source
            if compiler.debug?
              code.line "# Inlined partial #{template_name.inspect} at compile time"
              code.line "$stderr.puts '* WARN: Liquid file system access - inlined partial ' + #{template_name.inspect} + ' at compile time' if $VERBOSE"
            end
            # Generate a unique method name for this partial
            method_name = compiler.register_partial(template_name, partial_source)
            context_var_name = alias_name || template_name.split('/').last

            # Include shares scope, so we just set variables directly
            code.line "# Include: #{template_name}"

            # Set attributes
            attributes.each do |key, value|
              value_expr = ExpressionCompiler.compile(value, compiler)
              code.line "assigns[#{key.inspect}] = #{value_expr}"
            end

            # Set the context variable
            if variable_name_expr
              var_expr = ExpressionCompiler.compile(variable_name_expr, compiler)
              var_var = compiler.generate_var_name("incvar")
              code.line "#{var_var} = #{var_expr}"

              # If it's an array, loop through it
              code.line "if #{var_var}.is_a?(Array)"
              code.indent do
                code.line "#{var_var}.each do |__include_item__|"
                code.indent do
                  code.line "assigns[#{context_var_name.inspect}] = __include_item__"
                  code.line "__output__ << #{method_name}({})"
                end
                code.line "end"
              end
              code.line "else"
              code.indent do
                code.line "assigns[#{context_var_name.inspect}] = #{var_var}"
                code.line "__output__ << #{method_name}({})"
              end
              code.line "end"
            else
              # Try to find a variable with the same name as the template
              code.line "assigns[#{context_var_name.inspect}] = assigns[#{template_name.inspect}] if assigns.key?(#{template_name.inspect})"
              code.line "__output__ << #{method_name}({})"
            end
          else
            # Partial not found at compile time
            code.line "# Partial '#{template_name}' not found at compile time"
            compile_dynamic_include(tag, compiler, code)
          end
        end

        def self.compile_dynamic_include(tag, compiler, code)
          template_name_expr = tag.template_name_expr
          variable_name_expr = tag.variable_name_expr
          attributes = tag.attributes
          alias_name = tag.instance_variable_get(:@alias_name)

          if compiler.debug?
            code.line "# Dynamic include (template name from variable)"
          end

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

          # Call the external handler for dynamic includes
          code.line "__output__ << __external__.call(:include, #{name_expr}, #{var_expr}, #{attrs_var}, #{alias_expr}, assigns, __context__)"
        end
      end
    end
  end
end
