module Liquid
  class Case < Block
    Syntax     = /(#{QuotedFragment})/o
    WhenSyntax = /(#{QuotedFragment})(?:(?:\s+or\s+|\s*\,\s*)(#{QuotedFragment}.*))?/o

    def initialize(tag_name, markup, tokens)
      @blocks = []

      if markup =~ Syntax
        @left = $1
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.case"))
      end

      super
    end

    def nodelist
      @blocks.map(&:attachment).flatten
    end

    def unknown_tag(tag, markup, tokens)
      @nodelist = []
      case tag
      when 'when'
        record_when_condition(markup)
      when 'else'
        record_else_condition(markup)
      else
        super
      end
    end

    def render(context, output)
      context.stack do
        execute_else_block = true

        @blocks.each do |block|
          if block.else?
            return render_all(block.attachment, context, output) if execute_else_block
          elsif block.evaluate(context)
            execute_else_block = false
            render_all(block.attachment, context, output)
          end
        end
      end
    end

    private

    def record_when_condition(markup)
      while markup
        # Create a new nodelist and assign it to the new block
        if not markup =~ WhenSyntax
          raise SyntaxError.new(options[:locale].t("errors.syntax.case_invalid_when"))
        end

        markup = $2

        block = Condition.new(@left, '==', $1)
        block.attach(@nodelist)
        @blocks.push(block)
      end
    end

    def record_else_condition(markup)
      if not markup.strip.empty?
        raise SyntaxError.new(options[:locale].t("errors.syntax.case_invalid_else"))
      end

      block = ElseCondition.new
      block.attach(@nodelist)
      @blocks << block
    end
  end

  Template.register_tag('case', Case)
end
