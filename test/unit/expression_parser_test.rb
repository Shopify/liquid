# frozen_string_literal: true

require 'test_helper'

class ExpressionParserTest < Minitest::Test
  include Liquid

  def test_parse_returns_nil_for_empty_string
    result = ExpressionParser.parse('', parse_context)
    assert_nil(result)
  end

  def test_parse_returns_nil_for_whitespace_only
    result = ExpressionParser.parse('   ', parse_context)
    assert_nil(result)
  end

  def test_parse_raises_on_extra_tokens_after_expression
    error = assert_raises(SyntaxError) do
      ExpressionParser.parse('foo bar', parse_context)
    end
    assert_match(/Expected end_of_string but found id/, error.message)
  end

  def test_parse_string_literal_with_double_quotes
    result = ExpressionParser.parse('"hello"', parse_context)
    assert_equal('hello', result)
  end

  def test_parse_string_literal_with_single_quotes
    result = ExpressionParser.parse("'world'", parse_context)
    assert_equal('world', result)
  end

  def test_parse_integer_literal
    result = ExpressionParser.parse('42', parse_context)
    assert_equal(42, result)
  end

  def test_parse_float_literal
    result = ExpressionParser.parse('3.14', parse_context)
    assert_equal(3.14, result)
  end

  def test_parse_nil_literal
    result = ExpressionParser.parse('nil', parse_context)
    assert_nil(result)
  end

  def test_parse_true_literal
    result = ExpressionParser.parse('true', parse_context)
    assert_equal(true, result)
  end

  def test_parse_simple_variable
    result = ExpressionParser.parse('product', parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal('product', result.name)
  end

  def test_parse_variable_with_dot_lookup
    result = ExpressionParser.parse('product.title', parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal(['title'], result.lookups)
  end

  def test_parse_variable_with_bracket_lookup
    result = ExpressionParser.parse('items[0]', parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal('items', result.name)
    assert_equal(0, result.lookups[0])
  end

  def test_parse_range_with_integer_literals
    result = ExpressionParser.parse('(1..5)', parse_context)
    assert_kind_of(Range, result)
    assert_equal(1..5, result)
  end

  def test_parse_range_with_variables
    result = ExpressionParser.parse('(start..end)', parse_context)
    assert_kind_of(RangeLookup, result)
  end

  def test_parse_validates_end_of_string
    result = ExpressionParser.parse('foo', parse_context)
    assert_kind_of(VariableLookup, result)
  end

  def test_parse_evaluates_correctly
    result = ExpressionParser.parse('product.title', parse_context)
    context = Context.new({ 'product' => { 'title' => 'My Title' } })
    assert_equal('My Title', context.evaluate(result))
  end

  private

  def parse_context
    @parse_context ||= ParseContext.new(environment: Environment.build(error_mode: :rigid))
  end
end
