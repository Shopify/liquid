# frozen_string_literal: true

module Liquid
  module ExpressionParser
    class << self
      # Parses a Liquid expression string into an Expression object using
      # strict token-based validation.
      #
      # This method tokenizes the markup, validates that the expression
      # consumes all available tokens (no trailing garbage), and builds
      # an appropriate Expression object (literal, VariableLookup, or
      # RangeLookup).
      #
      # Returns nil if the markup is empty or contains only whitespace.
      #
      # Raises SyntaxError if:
      # - Invalid syntax is encountered
      # - Extra tokens remain after the expression
      #   (e.g., "product title" instead of "product.title")
      #
      # Examples:
      #   ExpressionParser.parse("product.title", ctx)
      #     #=> #<VariableLookup @name="product" @lookups=["title"]>
      #
      #   ExpressionParser.parse("42", ctx)
      #     #=> 42
      #
      #   ExpressionParser.parse("(1..10)", ctx)
      #     #=> 1..10
      #
      #   ExpressionParser.parse("", ctx)
      #     #=> nil
      #
      #   ExpressionParser.parse("product title", ctx)
      #     #=> raises SyntaxError (extra token "title")
      def parse(markup, parse_context)
        parser = parse_context.new_parser(markup)

        # Whitespaces only.
        return if parser.look(:end_of_string)

        result = ExpressionConsumer.consume(parser, parse_context)

        # Extra tokens after the expression.
        parser.consume(:end_of_string) unless parser.look(:end_of_string)

        result
      end
    end
  end
end
