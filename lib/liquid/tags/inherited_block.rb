module Liquid

  # Blocks are used with the Extends tag to define
  # the content of blocks. Nested blocks are allowed.
  #
  #   {% extends home %}
  #   {% block content }Hello world{% endblock %}
  #
  class InheritedBlock < Block
    Syntax = /(#{QuotedFragment}+)/

    attr_accessor :parent
    attr_accessor :nodelist
    attr_reader   :name

    def initialize(tag_name, markup, options)
      super

      if markup =~ Syntax
        @name = $1.gsub(/["']/o, '').strip
      else
        raise(SyntaxError.new(options[:locale].t("errors.syntax.block")), options[:line])
      end

      self.set_full_name!(options)

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
      self.register_current_block

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

    def self.clone_block(block)
      new_block = new(block.send(:instance_variable_get, :"@tag_name"), block.name, {})
      new_block.parent = block.parent
      new_block.nodelist = block.nodelist
      new_block
    end

    protected

    def set_full_name!(options)
      if options[:current_block]
        @name = options[:current_block].name + '/' + @name
      end
    end

    def register_current_block
      options[:blocks] ||= {}

      block = options[:blocks][@name]

      if block
        # copy the existing block in order to make it a parent of the parsed block
        new_block = self.class.clone_block(block)

        # replace the up-to-date version of the block in the parent template
        block.parent = new_block
        block.nodelist = @nodelist
      end
    end

  end

  class InheritedBlockDrop < Drop

    def initialize(block)
      @block = block
    end

    def name
      @block.name
    end

    def super
      @block.call_super(@context)
    end

  end

  Template.register_tag('block', InheritedBlock)
end