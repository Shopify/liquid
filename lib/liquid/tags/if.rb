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
      context.stack do
        @blocks.each do |block|
          if block.evaluate(context)
            return render_all(block.attachment, context)
          end
        end
        ''
      end
    rescue Condition::MustBeDeferred
      render_deferred(context)
    end

    private

      def push_block(tag, markup)
        block = if tag == 'else'
          ElseCondition.new
        else

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

        @blocks.push(block)
        @nodelist = block.attach(Array.new)
      end

      def render_deferred(context)
        first, out = true, ""
        @blocks.each do |block|
          if first
            first = false
            tag_name = @tag_name
          elsif ElseCondition === block
            tag_name = 'else'
          else
            tag_name = 'elsif'
          end
          out << "{%#{tag_name} #{block.to_markup(context)}%}"
          context.stack do
            context['__defer_assignment__'] = true
            out << render_all(block.attachment, context)
          end
        end

        out << "{%end#{@tag_name}%}"
        out
      end

  end

  Template.register_tag('if', If)
end
