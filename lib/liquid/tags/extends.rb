module Liquid

  # Extends allows designer to use template inheritance.
  #
  #   {% extends home %}
  #   {% block content }Hello world{% endblock %}
  #
  class Extends < Block
    Syntax = /(#{QuotedFragment}+)/o

    def initialize(tag_name, markup, options)
      super

      if markup =~ Syntax
        @template_name = $1.gsub(/["']/o, '').strip
      else
        raise(SyntaxError.new(options[:locale].t("errors.syntax.extends".freeze)))
      end

      # variables needed by the inheritance mechanism during the parsing
      options[:inherited_blocks] ||= {
        nested:   [], # used to get the full name of the blocks if nested (stack mechanism)
        all:      {}  # keep track of the blocks by their full name
      }
    end

    def parse(tokens)
      super

      parent_template = parse_parent_template

      # replace the nodes of the current template by those from the parent
      # which itself may have have done the same operation if it includes
      # the extends tag.
      nodelist.replace(parent_template.root.nodelist)
    end

    def blank?
      false
    end

    protected

    def parse_body(body, tokens)
      body.parse(tokens, options) do |end_tag_name, end_tag_params|
        @blank &&= body.blank?

        # Note: extends does not require the "end tag".
        return false if end_tag_name.nil?
      end

      true
    end

    def parse_parent_template
      source = Template.file_system.read_template_file(@template_name, {})
      Template.parse(source, options)
    end

  end

  Template.register_tag('extends', Extends)
end
