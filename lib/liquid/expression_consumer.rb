# frozen_string_literal: true

module Liquid
  module ExpressionConsumer
    INTEGER_REGEX = /\A(-?\d+)\z/
    FLOAT_REGEX   = /\A(-?\d+)\.\d+\z/

    LITERALS = {
      'nil' => nil,
      'null' => nil,
      'true' => true,
      'false' => false,
      'blank' => '',
      'empty' => '',
    }.freeze

    MINUS_VARIABLE_LOOKUP = VariableLookup.parse("-", nil).freeze

    class << self
      # Consumes tokens from a Parser instance to build an Expression
      # object.
      #
      # This method reads tokens from the current parser position,
      # consuming exactly one complete expression. The parser position is
      # advanced past the consumed tokens.
      #
      # Unlike ExpressionParser.parse, this method does NOT validate that
      # all tokens are consumed. It stops after consuming a complete
      # expression, leaving any remaining tokens for the caller to handle.
      #
      # This is the efficient low-level method used by tags that manage
      # their own Parser instances and need to consume multiple
      # expressions from a single token stream.
      #
      # Returns an Expression object appropriate for the token type:
      # - Literals (nil, true, false, numbers, strings)
      # - VariableLookup (variables with optional property/index access)
      # - RangeLookup or Range (for range expressions like (1..10))
      #
      # Raises SyntaxError if invalid token encountered.
      #
      # Examples:
      #   parser = parse_context.new_parser("product.title | upcase")
      #   expr = ExpressionConsumer.consume(parser, parse_context)
      #     #=> #<VariableLookup @name="product" @lookups=["title"]>
      #     # Parser is now positioned at the pipe token
      #
      #   parser = parse_context.new_parser("42")
      #   ExpressionConsumer.consume(parser, parse_context)
      #     #=> 42
      #
      #   parser = parse_context.new_parser("items[0]")
      #   ExpressionConsumer.consume(parser, parse_context)
      #     #=> #<VariableLookup @name="items" @lookups=[0]>
      def consume(parser, parse_context)
        token = parser.tokens[parser.point]

        case token[0]
        when :string
          str = parser.consume(:string)
          parse_string(str)
        when :number
          num_str = parser.consume(:number)
          parse_number(num_str)
        when :id
          parse_id(parser, parse_context)
        when :open_square
          # Bracket notation: [expression]
          parser.consume(:open_square)
          inner = consume(parser, parse_context)
          parser.consume(:close_square)
          lookups = parse_variable_lookups(parser, parse_context)
          build_variable_lookup(inner, lookups)
        when :open_round
          # Range notation: (start..end)
          parser.consume(:open_round)
          start_obj = consume(parser, parse_context)
          parser.consume(:dotdot)
          end_obj = consume(parser, parse_context)
          parser.consume(:close_round)
          build_range_lookup(start_obj, end_obj)
        else
          raise SyntaxError, "#{token} is not a valid expression"
        end
      end

      private

      def parse_string(str)
        str[1..-2]
      end

      def parse_number(num_str)
        case num_str
        when INTEGER_REGEX then Integer(num_str, 10)
        when FLOAT_REGEX   then num_str.to_f
        else
          raise Liquid::SyntaxError, "Invalid expression type in number expression"
        end
      end

      def parse_id(parser, parse_context)
        id_value = parser.consume(:id)
        lookups  = parse_variable_lookups(parser, parse_context)

        if LITERALS.key?(id_value)
          # Case: nil
          return LITERALS[id_value] if lookups.empty?

          # Case: nil.size
          return build_variable_lookup(id_value, lookups)
        end

        if id_value == '-'
          # Case (backwards compatibility): -
          return MINUS_VARIABLE_LOOKUP if lookups.empty?

          # Case: -var
          return build_variable_lookup('-', lookups)
        end

        # Case: var
        build_variable_lookup(id_value, lookups)
      end

      def parse_variable_lookups(parser, parse_context)
        lookups = []

        loop do
          if parser.look(:open_square)
            parser.consume(:open_square)
            lookup = consume(parser, parse_context)
            parser.consume(:close_square)
            lookups << lookup
            next
          end

          if parser.look(:dot)
            parser.consume(:dot)
            id = parser.consume(:id)
            lookups << id
            next
          end

          break
        end

        lookups
      end

      # todo(guilherme): avoid allocate, simplify this
      def build_variable_lookup(name, lookups)
        lookup = VariableLookup.allocate
        lookup.instance_variable_set(:@name, name)
        lookup.instance_variable_set(:@lookups, lookups)

        command_flags = 0
        lookups.each_with_index do |lookup_item, i|
          if lookup_item.is_a?(String) && VariableLookup::COMMAND_METHODS.include?(lookup_item)
            command_flags |= 1 << i
          end
        end
        lookup.instance_variable_set(:@command_flags, command_flags)

        lookup
      end

      # todo(guilherme): use RangeLookup.parse logic, simplify this
      def build_range_lookup(start_obj, end_obj)
        if !start_obj.respond_to?(:evaluate) && !end_obj.respond_to?(:evaluate)
          begin
            start_obj.to_i..end_obj.to_i
          rescue NoMethodError
            raise Liquid::SyntaxError, "Invalid expression type in range expression"
          end
        else
          RangeLookup.new(start_obj, end_obj)
        end
      end
    end
  end
end
