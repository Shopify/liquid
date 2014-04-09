module Liquid

  # Extends allows designer to use template inheritance
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
    end

    def parse(tokens)
      # get the nodes of the template the object inherits from
      parent_template = parse_parent_template

      # find the blocks in case there is a call to
      # the super method inside the current template
      @options.merge!(:blocks => self.find_blocks(parent_template.root.nodelist))

      # finally, process the rest of the tokens
      # the tags/blocks other than the InheritedBlock type will be ignored.
      super

      # replace the nodes of the current template by the ones from the parent
      @nodelist = parent_template.root.nodelist.clone
    end

    def blank?
      false
    end

    protected

    def find_blocks(nodelist, blocks = {})
      if nodelist
        nodelist.each_with_index do |node, index|
          # is the node an inherited block?
          if node.respond_to?(:call_super)
            new_node = node.clone_it

            nodelist.insert(index, new_node)
            nodelist.delete_at(index + 1)

            blocks[node.name] = new_node
          end
          if node.respond_to?(:nodelist)
            # find nested blocks too
            self.find_blocks(node.nodelist, blocks)
          end
        end
      end
      blocks
    end

    private

    def parse_parent_template
      source = Template.file_system.read_template_file(@template_name, {})
      Template.parse(source)
    end

    def assert_missing_delimitation!
    end
  end

  Template.register_tag('extends', Extends)
end