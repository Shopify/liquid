module Liquid
  #
  # TODO: docs
  #
  class Render < Tag
    Syntax = /(#{QuotedFragment}+)/o

    attr_reader :template_name_expr, :attributes

    def initialize(tag_name, markup, options)
      super

      if markup =~ Syntax
        template_name = $1

        @template_name_expr = Expression.parse(template_name)

        @attributes = {}
        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = Expression.parse(value)
        end

      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.include".freeze))
      end
    end

    def parse(_tokens)
    end

    def render_to_output_buffer(context, output)
      template_name = context.evaluate(@template_name_expr)
      raise ArgumentError.new(options[:locale].t("errors.argument.include")) unless template_name

      partial = load_cached_partial(template_name, context)

      inner_context = Context.new
      inner_context.template_name = template_name
      inner_context.partial = true
      @attributes.each do |key, value|
        inner_context[key] = context.evaluate(value)
      end
      partial.render_to_output_buffer(inner_context, output)
      
      # TODO: Put into a new #isolated_stack method in Context?
      inner_context.errors.each { |e| context.errors << e }

      output
    end

    private

    alias_method :parse_context, :options
    private :parse_context

    def load_cached_partial(template_name, context)
      cached_partials = context.registers[:cached_partials] || {}

      if cached = cached_partials[template_name]
        return cached
      end
      source = read_template_from_file_system(context)
      begin
        parse_context.partial = true
        partial = Liquid::Template.parse(source, parse_context)
      ensure
        parse_context.partial = false
      end
      cached_partials[template_name] = partial
      context.registers[:cached_partials] = cached_partials
      partial
    end

    def read_template_from_file_system(context)
      file_system = context.registers[:file_system] || Liquid::Template.file_system
      file_system.read_template_file(context.evaluate(@template_name_expr))
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [
          @node.template_name_expr,
        ] + @node.attributes.values
      end
    end
  end

  Template.register_tag('render'.freeze, Render)
end
