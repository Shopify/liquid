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
    SyntaxHelp = "Syntax Error in tag 'if' - Valid syntax: if [expression]"
    Syntax = /(#{QuotedFragment})\s*([=!<>a-z_]+)?\s*(#{QuotedFragment})?/o
    ExpressionsAndOperators = /(?:\b(?:\s?and\s?|\s?or\s?)\b|(?:\s*(?!\b(?:\s?and\s?|\s?or\s?)\b)(?:#{QuotedFragment}|\S+)\s*)+)/o

    def initialize(tag_name, markup, tokens)
      @blocks = []
      push_block('if', markup)
      super
    end

    def unknown_tag(tag, markup, tokens)
      if ['elsif', 'else'].include?(tag)
        push_block(tag, markup)
      else
        super
      end
    end

    def render(context)
      context.errors += @warnings if @warnings
      context.stack do
        @blocks.each do |block|
          if block.evaluate(context)
            return render_all(block.attachment, context)
          end
        end
        ''
      end
    end

    private

      def push_block(tag, markup)
        block = if tag == 'else'
          ElseCondition.new
        else
          parse_condition(markup)
        end

        @blocks.push(block)
        @nodelist = block.attach(Array.new)
      end

      def parse_condition(markup)
        case Template.error_mode
        when :strict then strict_parse(markup)
        when :lax    then lax_parse(markup)
        when :warn
          begin
            return strict_parse(markup)
          rescue SyntaxError => e
            @warnings ||= []
            @warnings << e
            return lax_parse(markup)
          end
        end
      end

      def lax_parse(markup)
        expressions = markup.scan(ExpressionsAndOperators).reverse
        raise(SyntaxError, SyntaxHelp) unless expressions.shift =~ Syntax

        condition = Condition.new($1, $2, $3)

        while not expressions.empty?
          operator = (expressions.shift).to_s.strip

          raise(SyntaxError, SyntaxHelp) unless expressions.shift.to_s =~ Syntax

          new_condition = Condition.new($1, $2, $3)
          new_condition.send(operator.to_sym, condition)
          condition = new_condition
        end

        condition
      end

      def strict_parse(markup)
        p = Parser.new(markup)

        condition = parse_comparison(p)

        while op = (p.id?('and') || p.id?('or'))
          new_cond = parse_comparison(p)
          new_cond.send(op.to_sym, condition)
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
