# frozen_string_literal: true

require 'test_helper'

class ParseContextUnitTest < Minitest::Test
  include Liquid

  def test_parser_expression_with_variable_lookup
    parser = parse_context.new_parser('product.title')
    result = parser.expression

    assert_instance_of(VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal(['title'], result.lookups)
  end

  def test_parser_expression_raises_syntax_error_for_invalid_expression
    parser = parse_context.new_parser('')

    error = assert_raises(Liquid::SyntaxError) do
      parser.expression
    end

    assert_match(/is not a valid expression/, error.message)
  end

  def test_parse_expression_with_variable_lookup
    result = parse_context.new_parser('product.title').expression

    assert_instance_of(VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal(['title'], result.lookups)
  end

  def test_parser_expression_advances_parser_pointer
    parser = parse_context.new_parser('foo, bar')

    # parser.expression consumes "foo"
    first_result = parser.expression
    assert_instance_of(VariableLookup, first_result)
    assert_equal('foo', first_result.name)

    parser.consume(:comma)

    # parser.expression consumes "bar"
    second_result = parser.expression
    assert_instance_of(VariableLookup, second_result)
    assert_equal('bar', second_result.name)

    parser.consume(:end_of_string)
  end

  private

  def parse_context
    @parse_context ||= ParseContext.new(
      environment: Environment.build,
    )
  end
end
