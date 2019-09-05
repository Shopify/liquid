module Liquid
  class Case < Block
    Syntax     = /(#{QuotedFragment})/o
    WhenSyntax = /(#{QuotedFragment})(?:(?:\s+or\s+|\s*\,\s*)(#{QuotedFragment}.*))?/om

    attr_reader :blocks, :left

    def initialize(tag_name, markup, options)
      super
      @blocks = []

      if markup =~ Syntax
        @left = Expression.parse($1)
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.case".freeze))
      end
    end

    def parse(tokens)
      body = BlockBody.new
      while parse_body(body, tokens)
        body = @blocks.last.attachment
      end
    end

    def format(left, right)
      output = "{%#{"-" if left} case #{Expression.format(@left)} #{"-" if @blocks[0].attachment.nodelist[-1].is_a?(Whitespace)}%}"
      output << format_blocks
      output << "{%#{"-" if @blocks[-1].attachment.nodelist[-1].is_a?(Whitespace)} endcase #{"-" if right}%}"
    end

    def format_blocks(last = "", open = false, output = "")
      @blocks.each_index do |idx|
        block = @blocks[idx]
        case block
        when ElseCondition
          output << " #{format_whitespace(last, 0)}%}#{last.format("")}{%#{format_whitespace(last, -1)} else" if open
          last = block.attachment
          open = true
        when Condition
          output << "{%#{format_whitespace(@blocks[0].attachment, -1)} when " unless open
          if block.attachment == last
            output << " or #{Expression.format(block.right)}"
          else
            output << " #{format_whitespace(last, 0)}%}#{last.format("")}{%#{format_whitespace(last, -1)} when " if open
            last = block.attachment
            output << Expression.format(block.right)
            open = true
          end
        else
          output << block
        end
      end
      output << " #{format_whitespace(last, 0)}%}#{last.format("")}" if open
    end

    def format_whitespace(block, pos)
      "-" if block.nodelist[pos].is_a?(Whitespace)
    end

    def nodelist
      @blocks.map(&:attachment)
    end

    def unknown_tag(tag, markup, tokens)
      case tag
      when 'when'.freeze
        record_when_condition(markup)
      when 'else'.freeze
        record_else_condition(markup)
      else
        super
      end
    end

    def render_to_output_buffer(context, output)
      context.stack do
        execute_else_block = true

        @blocks.each do |block|
          if block.else?
            block.attachment.render_to_output_buffer(context, output) if execute_else_block
          elsif block.evaluate(context)
            execute_else_block = false
            block.attachment.render_to_output_buffer(context, output)
          end
        end
      end

      output
    end

    private

    def record_when_condition(markup)
      body = BlockBody.new

      while markup
        unless markup =~ WhenSyntax
          raise SyntaxError.new(options[:locale].t("errors.syntax.case_invalid_when".freeze))
        end

        markup = $2

        block = Condition.new(@left, '=='.freeze, Expression.parse($1))
        block.attach(body)
        @blocks << block
      end
    end

    def record_else_condition(markup)
      unless markup.strip.empty?
        raise SyntaxError.new(options[:locale].t("errors.syntax.case_invalid_else".freeze))
      end

      block = ElseCondition.new
      block.attach(BlockBody.new)
      @blocks << block
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.left] + @node.blocks
      end
    end
  end

  Template.register_tag('case'.freeze, Case)
end
