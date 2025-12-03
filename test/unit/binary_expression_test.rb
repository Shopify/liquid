# frozen_string_literal: true

require 'test_helper'

class BinaryExpressionTest < Minitest::Test
  include Liquid

  def test_simple_comparison_evaluation
    assert_eval(false, BinaryExpression.new(5, ">", 5))
    assert_eval(true, BinaryExpression.new(5, ">=", 5))
    assert_eval(false, BinaryExpression.new(5, "<", 5))
    assert_eval(true, BinaryExpression.new(5, "<=", 5))
    assert_eval(true, BinaryExpression.new("abcd", "contains", "a"))
  end

  def test_complex_evaluation
    # 1 > 2 == 2 > 3
    assert_eval(true, BinaryExpression.new(
      BinaryExpression.new(1, '>', 2),
      '==',
      BinaryExpression.new(2, '>', 3),
    ))

    # 1 > 2 != 2 > 3
    assert_eval(false, BinaryExpression.new(
      BinaryExpression.new(1, '>', 2),
      '!=',
      BinaryExpression.new(2, '>', 3),
    ))

    # a > 0 == b.prop > 0
    assert_eval(
      true,
      BinaryExpression.new(
        BinaryExpression.new(var('a'), '>', 0),
        '==',
        BinaryExpression.new(var('b.prop'), '>', 0),
      ),
      { 'a' => 1, 'b' => { 'prop' => 2 } },
    )
  end

  def test_method_literal_equality
    empty = MethodLiteral.new(:empty?, '')

    # a == empty, empty == a
    assert_eval(false, BinaryExpression.new("123", "==", empty))
    assert_eval(true, BinaryExpression.new("", "==", empty))
    assert_eval(false, BinaryExpression.new(empty, "==", "123"))
    assert_eval(true, BinaryExpression.new(empty, "==", ""))

    # a does not have .empty?
    assert_eval(nil, BinaryExpression.new(1, "==", empty))
    assert_eval(nil, BinaryExpression.new(true, "==", empty))
    assert_eval(nil, BinaryExpression.new(false, "==", empty))
    assert_eval(nil, BinaryExpression.new(nil, "==", empty))

    # a != empty
    assert_eval(true, BinaryExpression.new("123", "!=", empty))
    assert_eval(false, BinaryExpression.new("", "!=", empty))
    assert_eval(true, BinaryExpression.new(empty, "!=", "123"))
    assert_eval(false, BinaryExpression.new(empty, "!=", ""))

    # a does not have .empty?
    assert_eval(true, BinaryExpression.new(1, "!=", empty))
    assert_eval(true, BinaryExpression.new(true, "!=", empty))
    assert_eval(true, BinaryExpression.new(false, "!=", empty))
    assert_eval(true, BinaryExpression.new(nil, "!=", empty))
  end

  def test_method_literal_comparison
    empty = MethodLiteral.new(:empty?, '')

    ['>', '>='].each do |op|
      assert_eval(nil, BinaryExpression.new("123", op, empty))
      assert_eval(nil, BinaryExpression.new("", op, empty))
      assert_eval(nil, BinaryExpression.new(empty, op, "123"))
      assert_eval(nil, BinaryExpression.new(empty, op, ""))
    end

    # Interesting case, contains on strings does include?(right.to_s)
    assert_eval(true, BinaryExpression.new("123", "contains", empty))
    assert_eval(true, BinaryExpression.new("", "contains", empty))
  end

  def assert_eval(expected, expr, assigns = {})
    actual = expr.evaluate(context(assigns))
    message = "Expected '#{expr}' to evaluate to '#{expected}'"
    return assert_nil(actual, message) if expected.nil?

    assert_equal(expected, actual, message)
  end

  def var(markup)
    Parser.new(markup).variable_lookup
  end

  def context(assigns = {})
    Context.build(outer_scope: assigns)
  end
end
