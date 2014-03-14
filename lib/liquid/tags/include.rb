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
    Syntax = /(#{QuotedFragment}+)(\s+(?:with|for)\s+(#{QuotedFragment}+))?/o

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax

        @template_name = $1
        @variable_name = $3
        @attributes    = {}

        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end

      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.include"))
      end

      super
    end

    def parse(tokens)
    end

    def blank?
      false
    end

    def render(context, output)
      partial = load_cached_partial(context)
      variable = context[@variable_name || @template_name[1..-2]]

      context.stack do
        @attributes.each do |key, value|
          context[key] = context[value]
        end

        context_variable_name = @template_name[1..-2].split('/').last
        if variable.is_a?(Array)
          variable.each do |var|
            context[context_variable_name] = var
            partial.render(context, :output => output)
          end
        else
          context[context_variable_name] = variable
          partial.render(context, :output => output)
        end
      end
    end

    private
      def load_cached_partial(context)
        cached_partials = context.registers[:cached_partials] || {}
        template_name = context[@template_name]

        if cached = cached_partials[template_name]
          return cached
        end
        source = read_template_from_file_system(context)
        partial = Liquid::Template.parse(source)
        cached_partials[template_name] = partial
        context.registers[:cached_partials] = cached_partials
        partial
      end

      def read_template_from_file_system(context)
        file_system = context.registers[:file_system] || Liquid::Template.file_system

        # make read_template_file call backwards-compatible.
        case file_system.method(:read_template_file).arity
        when 1
          file_system.read_template_file(context[@template_name])
        when 2
          file_system.read_template_file(context[@template_name], context)
        else
          raise ArgumentError, "file_system.read_template_file expects two parameters: (template_name, context)"
        end
      end
  end

  Template.register_tag('include', Include)
end
