# frozen_string_literal: true

require 'test_helper'

class ExpressionConsumerTest < Minitest::Test
  include Liquid

  def test_consume_string_literal_with_double_quotes
    parser = parse_context.new_parser('"hello"')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal('hello', result)
  end

  def test_consume_string_literal_with_single_quotes
    parser = parse_context.new_parser("'world'")
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal('world', result)
  end

  def test_consume_string_with_empty_content
    parser = parse_context.new_parser('""')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal('', result)
  end

  def test_consume_single_quote_empty_string
    parser = parse_context.new_parser("''")
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal('', result)
  end

  def test_consume_integer_literal
    parser = parse_context.new_parser('42')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(42, result)
    assert_kind_of(Integer, result)
  end

  def test_consume_negative_integer_literal
    parser = parse_context.new_parser('-42')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(-42, result)
  end

  def test_consume_float_literal
    parser = parse_context.new_parser('3.14')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(3.14, result)
    assert_kind_of(Float, result)
  end

  def test_consume_negative_float_literal
    parser = parse_context.new_parser('-3.14')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(-3.14, result)
  end

  def test_consume_zero_as_integer
    parser = parse_context.new_parser('0')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(0, result)
    assert_kind_of(Integer, result)
  end

  def test_consume_zero_as_float
    parser = parse_context.new_parser('0.0')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(0.0, result)
    assert_kind_of(Float, result)
  end

  def test_consume_nil_literal
    parser = parse_context.new_parser('nil')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_nil(result)
  end

  def test_consume_null_literal
    parser = parse_context.new_parser('null')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_nil(result)
  end

  def test_consume_true_literal
    parser = parse_context.new_parser('true')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(true, result)
  end

  def test_consume_false_literal
    parser = parse_context.new_parser('false')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(false, result)
  end

  def test_consume_blank_literal
    parser = parse_context.new_parser('blank')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal('', result)
  end

  def test_consume_empty_literal
    parser = parse_context.new_parser('empty')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal('', result)
  end

  def test_consume_nil_literal_with_lookups
    parser = parse_context.new_parser('nil.size')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal('nil', result.name)
    assert_equal(['size'], result.lookups)
  end

  def test_consume_true_literal_with_lookups
    parser = parse_context.new_parser('true.size')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal('true', result.name)
    assert_equal(['size'], result.lookups)
  end

  def test_consume_negative_number_parses_as_number
    parser = parse_context.new_parser('-5')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(-5, result)
  end

  def test_consume_simple_variable
    parser = parse_context.new_parser('product')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal([], result.lookups)
  end

  def test_consume_variable_with_dot_lookup
    parser = parse_context.new_parser('product.title')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal(['title'], result.lookups)
  end

  def test_consume_variable_with_multiple_dot_lookups
    parser = parse_context.new_parser('product.variants.first')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal(['variants', 'first'], result.lookups)
  end

  def test_consume_variable_with_bracket_lookup
    parser = parse_context.new_parser('items[0]')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal('items', result.name)
    assert_equal(0, result.lookups[0])
  end

  def test_consume_variable_with_bracket_string_lookup
    parser = parse_context.new_parser('items["key"]')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal('items', result.name)
    assert_equal('key', result.lookups[0])
  end

  def test_consume_variable_with_bracket_variable_lookup
    parser = parse_context.new_parser('items[index]')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal('index', result.lookups[0].name)
  end

  def test_consume_variable_with_mixed_lookups
    parser = parse_context.new_parser('product.variants[0].title')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal(3, result.lookups.length)
    assert_equal('variants', result.lookups[0])
    assert_equal(0, result.lookups[1])
    assert_equal('title', result.lookups[2])
  end

  def test_consume_bracket_notation_without_variable
    parser = parse_context.new_parser('[0]')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal(0, result.name)
  end

  def test_consume_bracket_notation_with_lookups
    parser = parse_context.new_parser('[0].title')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal(0, result.name)
    assert_equal(['title'], result.lookups)
  end

  def test_consume_bracket_notation_with_bracket_lookups
    parser = parse_context.new_parser('[0][1]')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_equal(0, result.name)
    assert_equal(1, result.lookups[0])
  end

  def test_consume_range_with_integer_literals
    parser = parse_context.new_parser('(1..5)')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(Range, result)
    assert_equal(1..5, result)
  end

  def test_consume_range_with_negative_integers
    parser = parse_context.new_parser('(-5..-1)')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(Range, result)
    assert_equal(-5..-1, result)
  end

  def test_consume_range_with_variable_start
    parser = parse_context.new_parser('(start..10)')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(RangeLookup, result)
    assert_kind_of(VariableLookup, result.start_obj)
    assert_equal(10, result.end_obj)
  end

  def test_consume_range_with_variable_end
    parser = parse_context.new_parser('(1..end)')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(RangeLookup, result)
    assert_equal(1, result.start_obj)
    assert_kind_of(VariableLookup, result.end_obj)
  end

  def test_consume_range_with_both_variables
    parser = parse_context.new_parser('(start..end)')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(RangeLookup, result)
    assert_kind_of(VariableLookup, result.start_obj)
    assert_kind_of(VariableLookup, result.end_obj)
  end

  def test_consume_range_with_variable_lookups
    parser = parse_context.new_parser('(start.value..end.value)')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(RangeLookup, result)
    assert_equal(['value'], result.start_obj.lookups)
  end

  def test_consume_command_method_size_sets_flag
    parser = parse_context.new_parser('items.size')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert(result.lookup_command?(0))
  end

  def test_consume_command_method_first_sets_flag
    parser = parse_context.new_parser('items.first')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert(result.lookup_command?(0))
  end

  def test_consume_command_method_last_sets_flag
    parser = parse_context.new_parser('items.last')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert(result.lookup_command?(0))
  end

  def test_consume_non_command_method_does_not_set_flag
    parser = parse_context.new_parser('items.title')
    result = ExpressionConsumer.consume(parser, parse_context)
    refute(result.lookup_command?(0))
  end

  def test_consume_advances_parser_position
    parser = parse_context.new_parser('foo.bar')
    ExpressionConsumer.consume(parser, parse_context)
    assert(parser.look(:end_of_string))
  end

  def test_consume_stops_before_extra_tokens
    parser = parse_context.new_parser('foo bar')
    ExpressionConsumer.consume(parser, parse_context)
    refute(parser.look(:end_of_string))
  end

  def test_consume_with_nested_brackets
    parser = parse_context.new_parser('items[items[0]]')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result)
    assert_kind_of(VariableLookup, result.lookups[0])
  end

  def test_consume_bracket_with_range
    parser = parse_context.new_parser('items[(1..3)]')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(Range, result.lookups[0])
    assert_equal(1..3, result.lookups[0])
  end

  def test_consume_raises_on_invalid_token_type
    parser = parse_context.new_parser('|')
    error = assert_raises(SyntaxError) do
      ExpressionConsumer.consume(parser, parse_context)
    end
    assert_match(/is not a valid expression/, error.message)
  end

  def test_consume_range_with_string_literals
    parser = parse_context.new_parser('("a".."z")')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(Range, result)
    assert_equal(0..0, result)
  end

  def test_consume_multiple_command_methods
    parser = parse_context.new_parser('items.first.size.last')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert(result.lookup_command?(0))
    assert(result.lookup_command?(1))
    assert(result.lookup_command?(2))
  end

  def test_consume_dot_after_bracket
    parser = parse_context.new_parser('items[0].title')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(0, result.lookups[0])
    assert_equal('title', result.lookups[1])
  end

  def test_consume_bracket_after_dot
    parser = parse_context.new_parser('product.variants[0]')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal('variants', result.lookups[0])
    assert_equal(0, result.lookups[1])
  end

  def test_consume_multiple_brackets_with_different_types
    parser = parse_context.new_parser('a[0]["key"][var]')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(0, result.lookups[0])
    assert_equal('key', result.lookups[1])
    assert_kind_of(VariableLookup, result.lookups[2])
  end

  def test_consume_deep_nested_brackets
    parser = parse_context.new_parser('a[b[c[d]]]')
    result = ExpressionConsumer.consume(parser, parse_context)
    inner1 = result.lookups[0]
    assert_kind_of(VariableLookup, inner1)
    inner2 = inner1.lookups[0]
    assert_kind_of(VariableLookup, inner2)
  end

  def test_consume_with_spaces_in_range
    parser = parse_context.new_parser('( 1 .. 10 )')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(1..10, result)
  end

  def test_consume_starting_with_bracket_then_dots
    parser = parse_context.new_parser('[0].first.last')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(0, result.name)
    assert(result.lookup_command?(0))
    assert(result.lookup_command?(1))
  end

  def test_consume_only_dot_lookups
    parser = parse_context.new_parser('a.b.c.d')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(['b', 'c', 'd'], result.lookups)
  end

  def test_consume_only_bracket_lookups
    parser = parse_context.new_parser('a[0][1][2]')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_equal(3, result.lookups.length)
    assert_equal(0, result.lookups[0])
    assert_equal(1, result.lookups[1])
    assert_equal(2, result.lookups[2])
  end

  def test_consume_complex_nested_expression
    parser = parse_context.new_parser('product.variants[index].title')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(VariableLookup, result.lookups[1])
    assert_equal('index', result.lookups[1].name)
  end

  def test_consume_range_with_bracketed_variables
    parser = parse_context.new_parser('(items[0]..items[1])')
    result = ExpressionConsumer.consume(parser, parse_context)
    assert_kind_of(RangeLookup, result)
    assert_kind_of(VariableLookup, result.start_obj)
  end

  def test_consume_evaluates_correctly
    parser = parse_context.new_parser('product')
    result = ExpressionConsumer.consume(parser, parse_context)
    context = Context.new({ 'product' => 'Test Product' })
    assert_equal('Test Product', context.evaluate(result))
  end

  def test_consume_with_lookups_evaluates_correctly
    parser = parse_context.new_parser('product.title')
    result = ExpressionConsumer.consume(parser, parse_context)
    context = Context.new({ 'product' => { 'title' => 'My Title' } })
    assert_equal('My Title', context.evaluate(result))
  end

  def test_consume_range_evaluates_correctly
    parser = parse_context.new_parser('(start..end)')
    result = ExpressionConsumer.consume(parser, parse_context)
    context = Context.new({ 'start' => 1, 'end' => 5 })
    assert_equal(1..5, context.evaluate(result))
  end

  private

  def parse_context
    @parse_context ||= ParseContext.new(environment: Environment.build(error_mode: :rigid))
  end
end
