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
    BOOLEAN_OPERATORS = %w(and or)

    def initialize(tag_name, markup, tokens)
      @blocks = []
      push_block('if', markup)
      super
    end

    def nodelist
      @blocks.map(&:attachment).flatten
    end

    def unknown_tag(tag, markup, tokens)
      if ['elsif', 'else'].include?(tag)
        push_block(tag, markup)
      else
        super
      end
    end

    def render(context, output)
      context.stack do
        @blocks.each do |block|
          if block.evaluate(context)
            return render_all(block.attachment, context, output)
          end
        end
      end
    end

    private

      def push_block(tag, markup)
        block = if tag == 'else'
          ElseCondition.new
        else
          parse_with_selected_parser(markup)
        end

        @blocks.push(block)
        @nodelist = block.attach(Array.new)
      end

      def lax_parse(markup)
        expressions = markup.scan(ExpressionsAndOperators).reverse
        raise(SyntaxError.new(options[:locale].t("errors.syntax.if"))) unless expressions.shift =~ Syntax

        condition = Condition.new($1, $2, $3)

        while not expressions.empty?
          operator = (expressions.shift).to_s.strip

          raise(SyntaxError.new(options[:locale].t("errors.syntax.if"))) unless expressions.shift.to_s =~ Syntax

          new_condition = Condition.new($1, $2, $3)
          raise(SyntaxError.new(options[:locale].t("errors.syntax.if"))) unless BOOLEAN_OPERATORS.include?(operator)
          new_condition.send(operator, condition)
          condition = new_condition
        end

        condition
      end

      def strict_parse(markup)
        p = Parser.new(markup)

        condition = parse_comparison(p)

        while op = (p.id?('and') || p.id?('or'))
          new_cond = parse_comparison(p)
          new_cond.send(op, condition)
          condition = new_cond
        end
        p.consume(:end_of_string)

        condition
      end

      def parse_comparison(p)
        a = p.expression
        if op = p.consume?(:comparison)
          b = p.expression
          Condition.new(a, op, b)
        else
          Condition.new(a)
        end
      end
  end

  Template.register_tag('if', If)
end
