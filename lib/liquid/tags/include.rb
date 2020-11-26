# frozen_string_literal: true

module Liquid
  # Include allows templates to relate with other templates
  #
  # Simply include another template:
  #
  #   {% include 'product' %}
  #
  # Include a template with a local variable:
  #
  #   {% include 'product' with products[0] %}
  #
  # Include a template for a collection:
  #
  #   {% include 'product' for products %}
  #
  class Include < Tag
    prepend Tag::Disableable

    SYNTAX = /(#{QuotedFragment}+)(\s+(?:with|for)\s+(#{QuotedFragment}+))?(\s+(?:as)\s+(#{VariableSegment}+))?/o
    Syntax = SYNTAX

    attr_reader :template_name_expr, :variable_name_expr, :attributes

    def initialize(tag_name, markup, options)
      super

      if markup =~ SYNTAX

        template_name = Regexp.last_match(1)
        variable_name = Regexp.last_match(3)

        @alias_name         = Regexp.last_match(5)
        @variable_name_expr = variable_name ? parse_expression(variable_name) : nil
        @template_name_expr = parse_expression(template_name)
        @attributes         = {}

        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = parse_expression(value)
        end

      else
        raise SyntaxError, options[:locale].t("errors.syntax.include")
      end
    end

    def parse(_tokens)
    end

    def render_to_output_buffer(context, output)
      template_name = context.evaluate(@template_name_expr)
      raise ArgumentError, options[:locale].t("errors.argument.include") unless template_name

      partial = PartialCache.load(
        template_name,
        context: context,
        parse_context: parse_context
      )

      context_variable_name = @alias_name || template_name.split('/').last

      variable = if @variable_name_expr
        context.evaluate(@variable_name_expr)
      else
        context.find_variable(template_name, raise_on_not_found: false)
      end

      old_template_name = context.template_name
      old_partial       = context.partial
      begin
        context.template_name = template_name
        context.partial       = true
        context.stack do
          @attributes.each do |key, value|
            context[key] = context.evaluate(value)
          end

          if variable.is_a?(Array)
            variable.each do |var|
              context[context_variable_name] = var
              partial.render_to_output_buffer(context, output)
            end
          else
            context[context_variable_name] = variable
            partial.render_to_output_buffer(context, output)
          end
        end
      ensure
        context.template_name = old_template_name
        context.partial       = old_partial
      end

      output
    end

    alias_method :parse_context, :options
    private :parse_context

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [
          @node.template_name_expr,
          @node.variable_name_expr,
        ] + @node.attributes.values
      end
    end
  end

  Template.register_tag('include', Include)
end
