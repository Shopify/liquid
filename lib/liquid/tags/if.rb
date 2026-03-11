# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category conditional
  # @liquid_name if
  # @liquid_summary
  #   Renders an expression if a specific condition is `true`.
  # @liquid_syntax
  #   {% if condition %}
  #     expression
  #   {% endif %}
  # @liquid_syntax_keyword condition The condition to evaluate.
  # @liquid_syntax_keyword expression The expression to render if the condition is met.
  class If < Block
    Syntax                  = /(#{QuotedFragment})\s*([=!<>a-z_]+)?\s*(#{QuotedFragment})?/o
    ExpressionsAndOperators = /(?:\b(?:\s?and\s?|\s?or\s?)\b|(?:\s*(?!\b(?:\s?and\s?|\s?or\s?)\b)(?:#{QuotedFragment}|\S+)\s*)+)/o
    BOOLEAN_OPERATORS       = %w(and or).freeze

    attr_reader :blocks

    def initialize(tag_name, markup, options)
      super
      @blocks = []
      push_block('if', markup)
    end

    def nodelist
      @blocks.map(&:attachment)
    end

    def parse(tokens)
      while parse_body(@blocks.last.attachment, tokens)
      end
      @blocks.reverse_each do |block|
        block.attachment.remove_blank_strings if blank?
        block.attachment.freeze
      end
    end

    ELSE_TAG_NAMES = ['elsif', 'else'].freeze
    private_constant :ELSE_TAG_NAMES

    def unknown_tag(tag, markup, tokens)
      if ELSE_TAG_NAMES.include?(tag)
        push_block(tag, markup)
      else
        super
      end
    end

    def render_to_output_buffer(context, output)
      @blocks.each do |block|
        result = Liquid::Utils.to_liquid_value(
          block.evaluate(context),
        )

        if result
          return block.attachment.render_to_output_buffer(context, output)
        end
      end

      output
    end

    private

    def strict2_parse(markup)
      strict_parse(markup)
    end

    def push_block(tag, markup)
      block = if tag == 'else'
        ElseCondition.new
      else
        parse_with_selected_parser(markup)
      end

      @blocks.push(block)
      block.attach(new_body)
    end

    def parse_expression(markup, safe: false)
      Condition.parse_expression(parse_context, markup, safe: safe)
    end

    # Fast path regex for simple conditions: "expr", "expr op expr" (no and/or)
    SIMPLE_CONDITION = /\A\s*(#{QuotedFragment})\s*(?:([=!<>a-z_]+)\s*(#{QuotedFragment}))?\s*\z/o

    # Operators indexed by first byte for fast lookup
    COMPARISON_OPS = {
      '==' => '==', '!=' => '!=', '<>' => '<>',
      '<=' => '<=', '>=' => '>=', '<' => '<', '>' => '>',
      'contains' => 'contains',
    }.freeze

    # Parse a simple condition "expr [op expr]" without regex.
    # Returns [left, op, right] or nil if not parseable.
    def self.parse_simple_condition(markup)
      len = markup.bytesize
      pos = 0

      # Skip leading whitespace
      pos += 1 while pos < len && (b = markup.getbyte(pos)) && (b == 32 || b == 9 || b == 10 || b == 13)
      return nil if pos >= len

      # Scan left expression (QuotedFragment): quoted string or non-whitespace/comma/pipe sequence
      left_start = pos
      b = markup.getbyte(pos)
      if b == 34 || b == 39 # quoted string
        quote = b
        pos += 1
        pos += 1 while pos < len && markup.getbyte(pos) != quote
        pos += 1 if pos < len # closing quote
      else
        # Non-whitespace, non-comma, non-pipe chars (QuotedFragment without quotes)
        while pos < len
          b = markup.getbyte(pos)
          break if b == 32 || b == 9 || b == 10 || b == 13 || b == 44 || b == 124 # space, tab, \n, \r, comma, pipe
          pos += 1
        end
      end
      left_end = pos

      return nil if left_start == left_end

      # Skip whitespace
      pos += 1 while pos < len && (b = markup.getbyte(pos)) && (b == 32 || b == 9 || b == 10 || b == 13)

      # End of markup? Simple truthiness
      if pos >= len
        left = markup.byteslice(left_start, left_end - left_start)
        return [left, nil, nil]
      end

      # Scan operator
      op_start = pos
      b = markup.getbyte(pos)
      if b == 61 || b == 33 || b == 60 || b == 62 # =, !, <, >
        pos += 1
        b2 = markup.getbyte(pos)
        pos += 1 if b2 && (b2 == 61 || b2 == 62) # second char of ==, !=, <=, >=, <>
      elsif b == 99 # 'c' for 'contains'
        while pos < len
          b = markup.getbyte(pos)
          break unless (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || b == 95
          pos += 1
        end
      else
        return nil # unknown operator start
      end
      op = markup.byteslice(op_start, pos - op_start)
      return nil unless COMPARISON_OPS.key?(op)
      op = COMPARISON_OPS[op] # use frozen string

      # Skip whitespace
      pos += 1 while pos < len && (b = markup.getbyte(pos)) && (b == 32 || b == 9 || b == 10 || b == 13)
      return nil if pos >= len # op without right operand

      # Scan right expression
      right_start = pos
      b = markup.getbyte(pos)
      if b == 34 || b == 39
        quote = b
        pos += 1
        pos += 1 while pos < len && markup.getbyte(pos) != quote
        pos += 1 if pos < len
      else
        while pos < len
          b = markup.getbyte(pos)
          break if b == 32 || b == 9 || b == 10 || b == 13 || b == 44 || b == 124
          pos += 1
        end
      end
      right_end = pos

      return nil if right_start == right_end

      # Skip trailing whitespace
      pos += 1 while pos < len && (b = markup.getbyte(pos)) && (b == 32 || b == 9 || b == 10 || b == 13)
      return nil unless pos >= len # extra stuff after right expr

      left = markup.byteslice(left_start, left_end - left_start)
      right = markup.byteslice(right_start, right_end - right_start)
      [left, op, right]
    end

    def lax_parse(markup)
      # Fastest path: simple identifier truthiness like "product.available" or "forloop.first"
      if (simple = Variable.simple_variable_markup(markup))
        return Condition.new(parse_expression(simple))
      end

      # Fast path: simple condition without and/or — manual byte parser
      if !markup.include?(' and ') && !markup.include?(' or ')
        parsed = If.parse_simple_condition(markup)
        if parsed
          left, op, right = parsed
          return Condition.new(
            parse_expression(left),
            op,
            right ? parse_expression(right) : nil,
          )
        end
      end

      expressions = markup.scan(ExpressionsAndOperators)
      raise SyntaxError, options[:locale].t("errors.syntax.if") unless expressions.pop =~ Syntax

      condition = Condition.new(parse_expression(Regexp.last_match(1)), Regexp.last_match(2), parse_expression(Regexp.last_match(3)))

      until expressions.empty?
        operator = expressions.pop.to_s.strip

        raise SyntaxError, options[:locale].t("errors.syntax.if") unless expressions.pop.to_s =~ Syntax

        new_condition = Condition.new(parse_expression(Regexp.last_match(1)), Regexp.last_match(2), parse_expression(Regexp.last_match(3)))
        raise SyntaxError, options[:locale].t("errors.syntax.if") unless BOOLEAN_OPERATORS.include?(operator)
        new_condition.send(operator, condition)
        condition = new_condition
      end

      condition
    end

    def strict_parse(markup)
      p = @parse_context.new_parser(markup)
      condition = parse_binary_comparisons(p)
      p.consume(:end_of_string)
      condition
    end

    def parse_binary_comparisons(p)
      condition = parse_comparison(p)
      first_condition = condition
      while (op = p.id?('and') || p.id?('or'))
        child_condition = parse_comparison(p)
        condition.send(op, child_condition)
        condition = child_condition
      end
      first_condition
    end

    def parse_comparison(p)
      a = parse_expression(p.expression, safe: true)
      if (op = p.consume?(:comparison))
        b = parse_expression(p.expression, safe: true)
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
end
