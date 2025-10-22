# frozen_string_literal: true

require 'test_helper'

class ParseContextUnitTest < Minitest::Test
  include Liquid

  def test_safe_parse_expression_with_variable_lookup
    parser_strict = strict_parse_context.new_parser('product.title')
    result_strict = strict_parse_context.safe_parse_expression(parser_strict)

    parser_rigid = rigid_parse_context.new_parser('product.title')
    result_rigid = rigid_parse_context.safe_parse_expression(parser_rigid)

    assert_instance_of(VariableLookup, result_strict)
    assert_equal('product', result_strict.name)
    assert_equal(['title'], result_strict.lookups)

    assert_instance_of(VariableLookup, result_rigid)
    assert_equal('product', result_rigid.name)
    assert_equal(['title'], result_rigid.lookups)
  end

  def test_safe_parse_expression_raises_syntax_error_for_invalid_expression
    parser_strict = strict_parse_context.new_parser('')
    parser_rigid = rigid_parse_context.new_parser('')

    error_strict = assert_raises(Liquid::SyntaxError) do
      strict_parse_context.safe_parse_expression(parser_strict)
    end
    assert_match(/is not a valid expression/, error_strict.message)

    error_rigid = assert_raises(Liquid::SyntaxError) do
      rigid_parse_context.safe_parse_expression(parser_rigid)
    end

    assert_match(/is not a valid expression/, error_rigid.message)
  end

  def test_parse_expression_with_variable_lookup
    result_strict = strict_parse_context.parse_expression('product.title')

    assert_instance_of(VariableLookup, result_strict)
    assert_equal('product', result_strict.name)
    assert_equal(['title'], result_strict.lookups)

    error = assert_raises(Liquid::InternalError) do
      rigid_parse_context.parse_expression('product.title')
    end

    assert_match(/unsafe parse_expression cannot be used in rigid mode/, error.message)
  end

  def test_parse_expression_with_safe_true
    result_strict = strict_parse_context.parse_expression('product.title', safe: true)

    assert_instance_of(VariableLookup, result_strict)
    assert_equal('product', result_strict.name)
    assert_equal(['title'], result_strict.lookups)

    result_rigid = rigid_parse_context.parse_expression('product.title', safe: true)

    assert_instance_of(VariableLookup, result_rigid)
    assert_equal('product', result_rigid.name)
    assert_equal(['title'], result_rigid.lookups)
  end

  def test_parse_expression_with_empty_string
    result_strict = strict_parse_context.parse_expression('')
    assert_nil(result_strict)

    error = assert_raises(Liquid::InternalError) do
      rigid_parse_context.parse_expression('')
    end

    assert_match(/unsafe parse_expression cannot be used in rigid mode/, error.message)
  end

  def test_parse_expression_with_empty_string_and_safe_true
    result_strict = strict_parse_context.parse_expression('', safe: true)
    assert_nil(result_strict)

    result_rigid = rigid_parse_context.parse_expression('', safe: true)
    assert_nil(result_rigid)
  end

  def test_safe_parse_expression_advances_parser_pointer
    parser = rigid_parse_context.new_parser('foo, bar')

    # safe_parse_expression consumes "foo"
    first_result = rigid_parse_context.safe_parse_expression(parser)
    assert_instance_of(VariableLookup, first_result)
    assert_equal('foo', first_result.name)

    parser.consume(:comma)

    # safe_parse_expression consumes "bar"
    second_result = rigid_parse_context.safe_parse_expression(parser)
    assert_instance_of(VariableLookup, second_result)
    assert_equal('bar', second_result.name)

    parser.consume(:end_of_string)
  end

  def test_parse_expression_with_whitespace_in_rigid_mode
    result = rigid_parse_context.parse_expression('   ', safe: true)
    assert_nil(result)
  end

  private

  def strict_parse_context
    @strict_parse_context ||= ParseContext.new(
      environment: Environment.build(error_mode: :strict),
    )
  end

  def rigid_parse_context
    @rigid_parse_context ||= ParseContext.new(
      environment: Environment.build(error_mode: :rigid),
    )
  end
end
