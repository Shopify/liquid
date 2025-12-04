# frozen_string_literal: true

require 'test_helper'

class ConditionUnitTest < Minitest::Test
  include Liquid

  def setup
    @context = Liquid::Context.new
  end

  def test_basic_condition
    assert_equal(false, Condition.new(1, '==', 2).evaluate(Context.new))
    assert_equal(true,  Condition.new(1, '==', 1).evaluate(Context.new))
  end

  def test_default_operators_evalute_true
    assert_evaluates_true(1, '==', 1)
    assert_evaluates_true(1, '!=', 2)
    assert_evaluates_true(1, '<>', 2)
    assert_evaluates_true(1, '<', 2)
    assert_evaluates_true(2, '>', 1)
    assert_evaluates_true(1, '>=', 1)
    assert_evaluates_true(2, '>=', 1)
    assert_evaluates_true(1, '<=', 2)
    assert_evaluates_true(1, '<=', 1)
    # negative numbers
    assert_evaluates_true(1, '>', -1)
    assert_evaluates_true(-1, '<', 1)
    assert_evaluates_true(1.0, '>', -1.0)
    assert_evaluates_true(-1.0, '<', 1.0)
  end

  def test_default_operators_evalute_false
    assert_evaluates_false(1, '==', 2)
    assert_evaluates_false(1, '!=', 1)
    assert_evaluates_false(1, '<>', 1)
    assert_evaluates_false(1, '<', 0)
    assert_evaluates_false(2, '>', 4)
    assert_evaluates_false(1, '>=', 3)
    assert_evaluates_false(2, '>=', 4)
    assert_evaluates_false(1, '<=', 0)
    assert_evaluates_false(1, '<=', 0)
  end

  def test_contains_works_on_strings
    assert_evaluates_true('bob', 'contains', 'o')
    assert_evaluates_true('bob', 'contains', 'b')
    assert_evaluates_true('bob', 'contains', 'bo')
    assert_evaluates_true('bob', 'contains', 'ob')
    assert_evaluates_true('bob', 'contains', 'bob')

    assert_evaluates_false('bob', 'contains', 'bob2')
    assert_evaluates_false('bob', 'contains', 'a')
    assert_evaluates_false('bob', 'contains', '---')
  end

  def test_contains_binary_encoding_compatibility_with_utf8
    assert_evaluates_true('🙈'.b, 'contains', '🙈')
    assert_evaluates_true('🙈', 'contains', '🙈'.b)
  end

  def test_invalid_comparation_operator
    assert_evaluates_argument_error(1, '~~', 0)
  end

  def test_comparation_of_int_and_str
    assert_evaluates_argument_error('1', '>', 0)
    assert_evaluates_argument_error('1', '<', 0)
    assert_evaluates_argument_error('1', '>=', 0)
    assert_evaluates_argument_error('1', '<=', 0)
  end

  def test_hash_compare_backwards_compatibility
    assert_nil(Condition.new({}, '>', 2).evaluate(Context.new))
    assert_nil(Condition.new(2, '>', {}).evaluate(Context.new))
    assert_equal(false, Condition.new({}, '==', 2).evaluate(Context.new))
    assert_equal(true, Condition.new({ 'a' => 1 }, '==', 'a' => 1).evaluate(Context.new))
    assert_equal(true, Condition.new({ 'a' => 2 }, 'contains', 'a').evaluate(Context.new))
  end

  def test_contains_works_on_arrays
    @context          = Liquid::Context.new
    @context['array'] = [1, 2, 3, 4, 5]
    array_expr        = VariableLookup.parse("array")

    assert_evaluates_false(array_expr, 'contains', 0)
    assert_evaluates_true(array_expr, 'contains', 1)
    assert_evaluates_true(array_expr, 'contains', 2)
    assert_evaluates_true(array_expr, 'contains', 3)
    assert_evaluates_true(array_expr, 'contains', 4)
    assert_evaluates_true(array_expr, 'contains', 5)
    assert_evaluates_false(array_expr, 'contains', 6)
    assert_evaluates_false(array_expr, 'contains', "1")
  end

  def test_contains_returns_false_for_nil_operands
    @context = Liquid::Context.new
    assert_evaluates_false(VariableLookup.parse('not_assigned'), 'contains', '0')
    assert_evaluates_false(0, 'contains', VariableLookup.parse('not_assigned'))
  end

  def test_contains_return_false_on_wrong_data_type
    assert_evaluates_false(1, 'contains', 0)
  end

  def test_contains_with_string_left_operand_coerces_right_operand_to_string
    assert_evaluates_true(' 1 ', 'contains', 1)
    assert_evaluates_false(' 1 ', 'contains', 2)
  end

  def test_or_condition
    condition = Condition.new(1, '==', 2)
    assert_equal(false, condition.evaluate(Context.new))

    condition.or(Condition.new(2, '==', 1))

    assert_equal(false, condition.evaluate(Context.new))

    condition.or(Condition.new(1, '==', 1))

    assert_equal(true, condition.evaluate(Context.new))
  end

  def test_and_condition
    condition = Condition.new(1, '==', 1)

    assert_equal(true, condition.evaluate(Context.new))

    condition.and(Condition.new(2, '==', 2))

    assert_equal(true, condition.evaluate(Context.new))

    condition.and(Condition.new(2, '==', 1))

    assert_equal(false, condition.evaluate(Context.new))
  end

  def test_left_or_right_may_contain_operators
    @context        = Liquid::Context.new
    @context['one'] = @context['another'] = "gnomeslab-and-or-liquid"

    assert_evaluates_true(VariableLookup.parse("one"), '==', VariableLookup.parse("another"))
  end

  def test_default_context_is_deprecated
    if Gem::Version.new(Liquid::VERSION) >= Gem::Version.new('6.0.0')
      flunk("Condition#evaluate without a context argument is to be removed")
    end

    _out, err = capture_io do
      assert_equal(true, Condition.new(1, '==', 1).evaluate)
    end

    expected = "DEPRECATION WARNING: Condition#evaluate without a context argument is deprecated" \
      " and will be removed from Liquid 6.0.0."
    assert_includes(err.lines.map(&:strip), expected)
  end

  def test_parse_expression
    environment = Environment.build
    parse_context = ParseContext.new(environment: environment)
    parser = parse_context.new_parser('product.title')
    result = parser.expression

    assert_instance_of(VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal(['title'], result.lookups)
  end

  def test_parser_expression_returns_method_literal_for_blank_and_empty
    environment = Environment.build
    parse_context = ParseContext.new(environment: environment)
    parser = parse_context.new_parser('blank')
    result = parser.expression

    assert_instance_of(MethodLiteral, result)
  end

  private

  def assert_evaluates_true(left, op, right)
    expr = BinaryExpression.new(left, op, right)
    assert(
      Condition.new(expr).evaluate(@context),
      "Evaluated false: #{left.inspect} #{op} #{right.inspect}",
    )
  end

  def assert_evaluates_false(left, op, right)
    expr = BinaryExpression.new(left, op, right)
    assert(
      !Condition.new(expr).evaluate(@context),
      "Evaluated true: #{left.inspect} #{op} #{right.inspect}",
    )
  end

  def assert_evaluates_argument_error(left, op, right)
    assert_raises(Liquid::ArgumentError) do
      expr = BinaryExpression.new(left, op, right)
      Condition.new(expr).evaluate(@context)
    end
  end
end # ConditionTest
