# frozen_string_literal: true

require 'test_helper'

class ParseContextUnitTest < Minitest::Test
  include Liquid

  def test_safe_parse_expression_with_variable_lookup
    parser = parse_context.new_parser('product.title')
    result = parse_context.safe_parse_expression(parser)

    assert_instance_of(VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal(['title'], result.lookups)
  end

  def test_safe_parse_expression_raises_syntax_error_for_invalid_expression
    parser = parse_context.new_parser('')

    error = assert_raises(Liquid::SyntaxError) do
      parse_context.safe_parse_expression(parser)
    end

    assert_match(/is not a valid expression/, error.message)
  end

  def test_parse_expression_with_variable_lookup
    error = assert_raises(Liquid::InternalError) do
      parse_context.parse_expression('product.title')
    end

    assert_match(/unsafe parse_expression cannot be used/, error.message)
  end

  def test_parse_expression_with_safe_true
    result = parse_context.parse_expression('product.title', safe: true)

    assert_instance_of(VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal(['title'], result.lookups)
  end

  def test_parse_expression_with_empty_string
    error = assert_raises(Liquid::InternalError) do
      parse_context.parse_expression('')
    end

    assert_match(/unsafe parse_expression cannot be used/, error.message)
  end

  def test_parse_expression_with_empty_string_and_safe_true
    result = parse_context.parse_expression('', safe: true)
    assert_nil(result)
  end

  def test_safe_parse_expression_advances_parser_pointer
    parser = parse_context.new_parser('foo, bar')

    # safe_parse_expression consumes "foo"
    first_result = parse_context.safe_parse_expression(parser)
    assert_instance_of(VariableLookup, first_result)
    assert_equal('foo', first_result.name)

    parser.consume(:comma)

    # safe_parse_expression consumes "bar"
    second_result = parse_context.safe_parse_expression(parser)
    assert_instance_of(VariableLookup, second_result)
    assert_equal('bar', second_result.name)

    parser.consume(:end_of_string)
  end

  def test_parse_expression_with_whitespace
    result = parse_context.parse_expression('   ', safe: true)
    assert_nil(result)
  end

  private

  def parse_context
    @parse_context ||= ParseContext.new(
      environment: Environment.build,
    )
  end
end
