# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category theme
  # @liquid_name render
  # @liquid_summary
  #   Renders a [snippet](/themes/architecture/snippets) or [app block](/themes/architecture/sections/section-schema#render-app-blocks).
  # @liquid_description
  #   Inside snippets and app blocks, you can't directly access variables that are [created](/docs/api/liquid/tags/variable-tags) outside
  #   of the snippet or app block. However, you can [specify variables as parameters](/docs/api/liquid/tags/render#render-passing-variables-to-a-snippet)
  #   to pass outside variables to snippets.
  #
  #   While you can't directly access created variables, you can access global objects, as well as any objects that are
  #   directly accessible outside the snippet or app block. For example, a snippet or app block inside the [product template](/themes/architecture/templates/product)
  #   can access the [`product` object](/docs/api/liquid/objects/product), and a snippet or app block inside a [section](/themes/architecture/sections)
  #   can access the [`section` object](/docs/api/liquid/objects/section).
  #
  #   Outside a snippet or app block, you can't access variables created inside the snippet or app block.
  #
  #   > Note:
  #   > When you render a snippet using the `render` tag, you can't use the [`include` tag](/docs/api/liquid/tags/include)
  #   > inside the snippet.
  # @liquid_syntax
  #   {% render 'filename' %}
  # @liquid_syntax_keyword filename The name of the snippet to render, without the `.liquid` extension.
  class Render < Tag
    FOR = 'for'
    AFTER = 'after'
    AFTER_MARKUP = /\s+#{AFTER}(?=\s|,|\z)/o
    WITH_OR_FOR_MARKUP = /\s+(with|#{FOR})\s+(#{QuotedFragment}+)/o
    ALIAS_MARKUP = /\s+(?:as)\s+(#{VariableSegment}+)/o
    SYNTAX = /(#{QuotedString}+)(#{AFTER_MARKUP})?(#{WITH_OR_FOR_MARKUP})?(#{ALIAS_MARKUP})?/o

    disable_tags "include"

    attr_reader :template_name_expr, :variable_name_expr, :attributes, :alias_name

    def initialize(tag_name, markup, options)
      super

      raise SyntaxError, options[:locale].t("errors.syntax.render") unless markup =~ SYNTAX

      template_name = Regexp.last_match(1)
      @after = !!Regexp.last_match(2)
      with_or_for = Regexp.last_match(4)
      variable_name = Regexp.last_match(5)

      @alias_name = Regexp.last_match(7)
      @variable_name_expr = variable_name ? parse_expression(variable_name) : nil
      @template_name_expr = parse_expression(template_name)
      @is_for_loop = (with_or_for == FOR)

      @attributes = {}
      markup.scan(TagAttributes) do |key, value|
        @attributes[key] = parse_expression(value)
      end
    end

    def for_loop?
      @is_for_loop
    end

    def render_to_output_buffer(context, output)
      render_tag(context, output)
    end

    def after?
      @after
    end

    def render_tag(context, output)
      # The expression should be a String literal, which parses to a String object
      template_name = @template_name_expr
      raise ::ArgumentError unless template_name.is_a?(String)

      partial = PartialCache.load(
        template_name,
        context: context,
        parse_context: parse_context,
      )

      context_variable_name = @alias_name || template_name.split('/').last

      evaluated_attributes = @attributes.transform_values { |value| context.evaluate(value) }

      render_partial_func = ->(var, forloop, render_output) {
        inner_context               = context.new_isolated_subcontext
        inner_context.template_name = partial.name
        inner_context.partial       = true
        inner_context['forloop']    = forloop if forloop

        evaluated_attributes.each do |key, value|
          inner_context[key] = value
        end
        inner_context[context_variable_name] = var unless var.nil?
        partial.render_to_output_buffer(inner_context, render_output)
        forloop&.send(:increment!)
      }

      variable = @variable_name_expr ? context.evaluate(@variable_name_expr) : nil

      if @after
        id = context.next_after_render_id
        context.enqueue_after_render(
          id: id,
          renderer: ->(after_output) {
            if @is_for_loop && variable.respond_to?(:each) && variable.respond_to?(:count)
              forloop = Liquid::ForloopDrop.new(template_name, variable.count, nil)
              variable.each { |var| render_partial_func.call(var, forloop, after_output) }
            else
              render_partial_func.call(variable, nil, after_output)
            end
          }
        )
        output << %(<?marker name="#{id}">)
      elsif @is_for_loop && variable.respond_to?(:each) && variable.respond_to?(:count)
        forloop = Liquid::ForloopDrop.new(template_name, variable.count, nil)
        variable.each { |var| render_partial_func.call(var, forloop, output) }
      else
        render_partial_func.call(variable, nil, output)
      end

      output
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [
          @node.template_name_expr,
          @node.variable_name_expr,
        ] + @node.attributes.values
      end
    end
  end
end
