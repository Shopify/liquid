# frozen_string_literal: true

module Liquid
  class Render < Tag
    SYNTAX = /(#{QuotedString}+)(\s+(?:with|for)\s+(#{QuotedFragment}+))?(\s+(?:as)\s+(#{VariableSegment}+))?/o

    disable_tags "include"

    attr_reader :template_name_expr, :attributes

    def initialize(tag_name, markup, options)
      super

      raise SyntaxError, options[:locale].t("errors.syntax.render") unless markup =~ SYNTAX

      template_name = Regexp.last_match(1)
      variable_name = Regexp.last_match(3)

      @alias_name = Regexp.last_match(5)
      @variable_name_expr = variable_name ? Expression.parse(variable_name) : nil
      @template_name_expr = Expression.parse(template_name)

      @attributes = {}
      markup.scan(TagAttributes) do |key, value|
        @attributes[key] = Expression.parse(value)
      end
    end

    def render_to_output_buffer(context, output)
      render_tag(context, output)
    end

    def render_tag(context, output)
      # Though we evaluate this here we will only ever parse it as a string literal.
      template_name = context.evaluate(@template_name_expr)
      raise ArgumentError, options[:locale].t("errors.argument.include") unless template_name

      partial = PartialCache.load(
        template_name,
        context: context,
        parse_context: parse_context
      )

      context_variable_name = @alias_name || template_name.split('/').last

      render_partial_func = ->(var, forloop) {
        inner_context               = context.new_isolated_subcontext
        inner_context.template_name = template_name
        inner_context.partial       = true
        inner_context['forloop']    = forloop if forloop

        @attributes.each do |key, value|
          inner_context[key] = context.evaluate(value)
        end
        inner_context[context_variable_name] = var unless var.nil?
        partial.render_to_output_buffer(inner_context, output)
        forloop&.send(:increment!)
      }

      variable = @variable_name_expr ? context.evaluate(@variable_name_expr) : nil
      if variable.is_a?(Array)
        forloop = Liquid::ForloopDrop.new(template_name, variable.count, nil)
        variable.each { |var| render_partial_func.call(var, forloop) }
      else
        render_partial_func.call(variable, nil)
      end

      output
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [
          @node.template_name_expr,
        ] + @node.attributes.values
      end
    end
  end

  Template.register_tag('render', Render)
end
