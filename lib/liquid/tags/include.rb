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

    def initialize(tag_name, markup, options)
      super

      if markup =~ Syntax

        @template_name = $1
        @variable_name = $3
        @attributes    = {}

        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end

        if partial_parsable_at_parse_time?
          source = read_template_from_file_system_at_parse
          @partial = Liquid::Template.parse(source, pass_options)
        end

      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.include".freeze))
      end
    end

    def parse(tokens)
    end

    def render(context)
      partial = load_cached_partial(context)
      variable = context[@variable_name || @template_name[1..-2]]

      context.stack do
        @attributes.each do |key, value|
          context[key] = context[value]
        end

        context_variable_name = @template_name[1..-2].split('/'.freeze).last
        if variable.is_a?(Array)
          variable.collect do |var|
            context[context_variable_name] = var
            partial.render(context)
          end
        else
          context[context_variable_name] = variable
          partial.render(context)
        end
      end
    end

    private
      def load_cached_partial(context)
        cached_partials = context.registers[:cached_partials] || {}
        template_name = context[@template_name]

        if cached = cached_partials[template_name]
          cached
        else
          if @partial
            partial = @partial
          else
            partial = Liquid::Template.parse(read_template_from_file_system(context), pass_options)
          end
          cached_partials[template_name] = partial
          context.registers[:cached_partials] = cached_partials
          partial
        end
      end

      def read_template_from_file_system(context)
        file_system = context.registers[:file_system] || Liquid::Template.file_system

        file_system.read_template_file(context[@template_name])
      end

      def read_template_from_file_system_at_parse
        parsed_file_system.read_template_file(parsed_template_name)
      end

      def parsed_file_system
        options[:file_system]
      end

      def partial_parsable_at_parse_time?
        template_name_is_string_constant = parsed_template_name.is_a?(String)
        options[:file_system] && template_name_is_string_constant
      end

      def parsed_template_name
        Expression.parse(@template_name)
      end

      def pass_options
        dont_pass = @options[:include_options_blacklist]
        return {locale: @options[:locale]} if dont_pass == true
        opts = @options.merge(included: true, include_options_blacklist: false)
        if dont_pass.is_a?(Array)
          dont_pass.each {|o| opts.delete(o)}
        end
        opts
      end
  end

  Template.register_tag('include'.freeze, Include)
end
