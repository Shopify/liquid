module Liquid
  # If is the conditional block
  #
  #   {% if user.admin %}
  #     Admin user!
  #   {% else %}
  #     Not admin user
  #   {% endif %}
  #
  #    There are {% if count < 5 %} less {% else %} more {% endif %} items than you need.
  #
  class If < Block
    Syntax = /(#{QuotedFragment})\s*([=!<>a-z_]+)?\s*(#{QuotedFragment})?/o
    ExpressionsAndOperators = /(?:\b(?:\s?and\s?|\s?or\s?)\b|(?:\s*(?!\b(?:\s?and\s?|\s?or\s?)\b)(?:#{QuotedFragment}|\S+)\s*)+)/o
    BOOLEAN_OPERATORS = %w(and or).freeze

    attr_reader :blocks

    def initialize(tag_name, markup, options)
      super
      @blocks = []
      push_block('if'.freeze, markup)
    end

    def nodelist
      @blocks.map(&:attachment)
    end

    def parse(tokens)
      while parse_body(@blocks.last.attachment, tokens)
      end
    end

    def format(left, right)
      format_blocks(left, right)
    end

    def format_blocks(left, right, type = "if", output = "")
      first = true
      @blocks.each_index do |idx|
        block_last = @blocks[idx - 1]
        block = @blocks[idx]
        case block
        when ElseCondition
          output << "{%#{"-" if block_last.attachment.nodelist[-1].is_a?(Whitespace)} else #{"-" if block.attachment.nodelist[0].is_a?(Whitespace)}%}"
          output << block.attachment.format("")
        when Condition
          output << "{%#{"-" if left && first}#{whitespace_last(block_last, first)} #{first ? type : "elsif"} #{block.format} #{"-" if block.attachment.nodelist[0].is_a?(Whitespace)}%}"
          output << block.attachment.format("")
          first = false
        else
          output << ""
        end
      end
      output << "{%#{"-" if @blocks[-1].attachment.nodelist[-1].is_a?(Whitespace)} end#{type} #{"-" if right}%}"
      output
    end

    def whitespace_last(block_last, first)
      "-" if block_last.attachment.nodelist[-1].is_a?(Whitespace) && !first
    end

    def unknown_tag(tag, markup, tokens)
      if ['elsif'.freeze, 'else'.freeze].include?(tag)
        push_block(tag, markup)
      else
        super
      end
    end

    def render_to_output_buffer(context, output)
      context.stack do
        @blocks.each do |block|
          if block.evaluate(context)
            return block.attachment.render_to_output_buffer(context, output)
          end
        end
      end

      output
    end

    private

    def push_block(tag, markup)
      block = if tag == 'else'.freeze
        ElseCondition.new
      else
        parse_with_selected_parser(markup)
      end

      @blocks.push(block)
      block.attach(BlockBody.new)
    end

    def lax_parse(markup)
      expressions = markup.scan(ExpressionsAndOperators)
      raise(SyntaxError.new(options[:locale].t("errors.syntax.if".freeze))) unless expressions.pop =~ Syntax

      condition = Condition.new(Expression.parse($1), $2, Expression.parse($3))

      until expressions.empty?
        operator = expressions.pop.to_s.strip

        raise(SyntaxError.new(options[:locale].t("errors.syntax.if".freeze))) unless expressions.pop.to_s =~ Syntax

        new_condition = Condition.new(Expression.parse($1), $2, Expression.parse($3))
        raise(SyntaxError.new(options[:locale].t("errors.syntax.if".freeze))) unless BOOLEAN_OPERATORS.include?(operator)
        new_condition.send(operator, condition)
        condition = new_condition
      end

      condition
    end

    def strict_parse(markup)
      p = Parser.new(markup)
      condition = parse_binary_comparisons(p)
      p.consume(:end_of_string)
      condition
    end

    def parse_binary_comparisons(p)
      condition = parse_comparison(p)
      first_condition = condition
      while op = (p.id?('and'.freeze) || p.id?('or'.freeze))
        child_condition = parse_comparison(p)
        condition.send(op, child_condition)
        condition = child_condition
      end
      first_condition
    end

    def parse_comparison(p)
      a = Expression.parse(p.expression)
      if op = p.consume?(:comparison)
        b = Expression.parse(p.expression)
        Condition.new(a, op, b)
      else
        Condition.new(a)
      end
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        @node.blocks
      end
    end
  end

  Template.register_tag('if'.freeze, If)
end
