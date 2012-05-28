module Liquid
  class Include < Tag
    Syntax = /(#{QuotedFragment}+)(\s+(?:with|for)\s+(#{QuotedFragment}+))?/

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax

        @template_name = $1
        @variable_name = $3
        @attributes    = {}

        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end

      else
        raise SyntaxError.new("Error in tag 'include' - Valid syntax: include '[template]' (with|for) [object|collection]")
      end

      super
    end

    def parse(tokens)
    end

    def render(context)
      context.stack do
        template = _read_template_from_file_system(context)
        partial = Liquid::Template.parse _template_source(template)
        variable = context[@variable_name || @template_name[1..-2]]

        @attributes.each do |key, value|
          context[key] = context[value]
        end

        if variable.is_a?(Array)
          variable.collect do |variable|
            context[@template_name[1..-2]] = variable
            _render_partial(partial, template, context)
          end
        else
          context[@template_name[1..-2]] = variable
          _render_partial(partial, template, context)
        end
      end
    end

  private
    def _template_source(template)
      template
    end

    def _render_partial(partial, template, context)
      partial.render(context)
    end

    def _read_template_from_file_system(context)
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