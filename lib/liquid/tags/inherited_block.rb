module Liquid

  # Blocks are used with the Extends tag to define
  # the content of blocks. Nested blocks are allowed.
  #
  #   {% extends home %}
  #   {% block content }Hello world{% endblock %}
  #
  class InheritedBlock < Block
    Syntax = /(#{QuotedFragment}+)/o

    attr_reader :name, :parent

    def initialize(tag_name, markup, options)
      super

      if markup =~ Syntax
        @name = $1.gsub(/["']/o, '').strip
      else
        raise(SyntaxError.new(options[:locale].t("errors.syntax.block")), options[:line])
      end

      set_full_name!(options)

      (options[:block_stack] ||= []).push(self)
      options[:current_block] = self
    end

    def render(context)
      context.stack do
        context['block'] = InheritedBlockDrop.new(self)
        render_all(@nodelist, context)
      end
    end

    def end_tag
      link_it_with_ancestor

      # clean the stack
      options[:block_stack].pop
      options[:current_block] = options[:block_stack].last
    end

    def call_super(context)
      if parent
        parent.render(context)
      else
        ''
      end
    end

    def clone_it
      self.class.clone_it(self)
    end

    def attach_parent(parent, nodelist)
      @parent   = parent
      @nodelist = nodelist
    end

    def self.clone_it(block)
      new_block = new(block.block_name, block.name, {})
      new_block.attach_parent(block.parent, block.nodelist)
      new_block
    end

    private

    def set_full_name!(options)
      if options[:current_block]
        @name = options[:current_block].name + '/' + @name
      end
    end

    def link_it_with_ancestor
      options[:blocks] ||= {}

      block = options[:blocks][@name]

      if block
        # copy/clone the existing block in order to make it a parent of the parsed block
        cloned_block = block.clone_it

        # replace the up-to-date version of the block in the parent template
        block.attach_parent(cloned_block, @nodelist)
      end
    end

  end

  Template.register_tag('block', InheritedBlock)
end