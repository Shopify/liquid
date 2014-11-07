module Liquid
  class Case < Block
    Syntax     = /(#{QuotedFragment})/o
    WhenSyntax = /(#{QuotedFragment})(?:(?:\s+or\s+|\s*\,\s*)(#{QuotedFragment}.*))?/om

    def initialize(tag_name, markup, options)
      super
      @blocks = []

      if markup =~ Syntax
        @left = $1
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.case".freeze))
      end
    end

    def nodelist
      @blocks.flat_map(&:attachment)
    end

    def unknown_tag(tag, markup, tokens)
      @nodelist = []
      case tag
      when 'when'.freeze
        record_when_condition(markup)
      when 'else'.freeze
        record_else_condition(markup)
      else
        super
      end
    end

    def render(context)
      context.stack do
        execute_else_block = true

        output = ''
        @blocks.each do |block|
          if block.else?
            return render_all(block.attachment, context) if execute_else_block
          elsif block.evaluate(context)
            execute_else_block = false
            output << render_all(block.attachment, context)
          end
        end
        output
      end
    end

    private

    def record_when_condition(markup)
      while markup
        # Create a new nodelist and assign it to the new block
        if not markup =~ WhenSyntax
          raise SyntaxError.new(options[:locale].t("errors.syntax.case_invalid_when".freeze))
        end

        markup = $2

        block = Condition.new(@left, '=='.freeze, $1)
        block.attach(@nodelist)
        @blocks.push(block)
      end
    end

    def record_else_condition(markup)
      if not markup.strip.empty?
        raise SyntaxError.new(options[:locale].t("errors.syntax.case_invalid_else".freeze))
      end

      block = ElseCondition.new
      block.attach(@nodelist)
      @blocks << block
    end
  end

  Template.register_tag('case'.freeze, Case)
end
