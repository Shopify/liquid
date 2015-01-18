module Liquid

  # Blocks are used with the Extends tag to define
  # the content of blocks. Nested blocks are allowed.
  #
  #   {% extends home %}
  #   {% block content }Hello world{% endblock %}
  #
  class InheritedBlock < Block
    Syntax = /(#{QuotedFragment}+)/o

    attr_reader   :name

    # linked chain of inherited blocks included
    # in different templates if multiple extends
    attr_accessor :parent, :descendant

    def initialize(tag_name, markup, options)
      super

      if markup =~ Syntax
        @name = $1.gsub(/["']/o, '').strip
      else
        raise(SyntaxError.new(options[:locale].t("errors.syntax.block")), options[:line])
      end

      prepare_for_inheritance
    end

    def prepare_for_inheritance
      # give a different name if this is a nested block
      if block = options[:inherited_blocks][:nested].last
        @name = "#{block.name}/#{@name}"
      end

      # append this block to the stack in order to
      # get a name for the other nested inherited blocks
      options[:inherited_blocks][:nested].push(self)

      # build the linked chain of inherited blocks
      # make a link with the descendant and the parent (chained list)
      if descendant = options[:inherited_blocks][:all][@name]
        self.descendant   = descendant
        descendant.parent = self

        # get the value of the blank property from the descendant
        @blank = descendant.blank? #false
      end

      # become the descendant of the inherited block from the parent template
      options[:inherited_blocks][:all][@name] = self
    end

    def parse(tokens)
      super

      # when the parsing of the block is done, we can then remove it from the stack
      options[:inherited_blocks][:nested].pop
    end

    alias_method :render_without_inheritance, :render

    def render(context)
      context.stack do
        # look for the very first descendant
        block = self_or_first_descendant

        if block != self
          # the block drop is in charge of rendering "{{ block.super }}"
          context['block'] = InheritedBlockDrop.new(block)
        end

        block.render_without_inheritance(context)
      end
    end

    # when we render an inherited block, we need the version of the
    # very first descendant.
    def self_or_first_descendant
      block = self
      while block.descendant; block = block.descendant; end
      block
    end

    def call_super(context)
      if parent
        # remove the block from the linked chain
        parent.descendant = nil

        parent.render(context)
      else
        ''
      end
    end

  end

  Template.register_tag('block', InheritedBlock)
end
