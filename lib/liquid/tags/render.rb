# frozen_string_literal: true

module Liquid
  class Render < Tag
    FOR = 'for'
    SYNTAX = %r{
      (
        ## for {% render "snippet" %}
        #{Liquid::QuotedString}+ |
        ## for {% render block %}
        \A#{Liquid::VariableSegment}+
      )
      ## for {% render "snippet" with product as p %}
      ## or  {% render "snippet" for products p %}
      (\s+(with|#{Liquid::Render::FOR})\s+(#{Liquid::QuotedFragment}+))?
      (\s+(?:as)\s+(#{Liquid::VariableSegment}+))?
      ## variables passed into the tag (e.g. {% render "snippet", var1: value1, var2: value2 %}
      ## are not matched by this regex and are handled by .initialize
    }xo

    disable_tags "include"

    attr_reader :template_name_expr, :attributes

    def initialize(tag_name, markup, options)
      super

      raise SyntaxError, options[:locale].t("errors.syntax.render") unless markup =~ SYNTAX

      @template_name = Regexp.last_match(1)
      with_or_for = Regexp.last_match(3)
      variable_name = Regexp.last_match(4)

      @alias_name = Regexp.last_match(6)
      @variable_name_expr = variable_name ? parse_expression(variable_name) : nil
      @template_name_expr = parse_expression(@template_name)
      @for = (with_or_for == FOR)

      @attributes = {}
      markup.scan(TagAttributes) do |key, value|
        @attributes[key] = parse_expression(value)
      end
    end

    def render_to_output_buffer(context, output)
      render_tag(context, output)
    end

    def render_tag(context, output)
      render_target = context.evaluate(@template_name_expr)
      raise ArgumentError, options[:locale].t("errors.argument.render") unless render_target

      # Check to see if this is a renderable drop
      if render_target.is_a?(Liquid::RenderableDrop)
        return render_target.render(context, output)
      end

      # Otherwise it must be a quoted string
      unless /#{Liquid::QuotedString}+/.match?(@template_name)
        output << "<!-- #{options[:locale].t('errors.syntax.render')} -->"
        return
      end

      template_name = render_target

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
      if @for && variable.respond_to?(:each) && variable.respond_to?(:count)
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
