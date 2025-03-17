# frozen_string_literal: true

require 'test_helper'
require 'test_boolean_helper'

class LogicalExpressionTest < Minitest::Test
  include Liquid

  def setup
    @ss = StringScanner.new("")
    @cache = {}
  end

  def test_logical_detection
    assert(Expression::LogicalExpression.logical?("foo and bar"))
    assert(Expression::LogicalExpression.logical?("foo or bar"))
    assert(Expression::LogicalExpression.logical?("true and false"))
    assert(Expression::LogicalExpression.logical?("1 or 0"))

    refute(Expression::LogicalExpression.logical?("foo"))
    refute(Expression::LogicalExpression.logical?("1 == 1"))
    refute(Expression::LogicalExpression.logical?("a contains b"))
    refute(Expression::LogicalExpression.logical?("not foo"))
  end

  def test_parenthesized_logical_detection
    assert(Expression::LogicalExpression.logical?("a and (b or c)"))
    assert(Expression::LogicalExpression.logical?("(a or b) and c"))
  end

  def test_boolean_operator_detection
    assert(Expression::LogicalExpression.boolean_operator?("and"))
    assert(Expression::LogicalExpression.boolean_operator?("or"))

    refute(Expression::LogicalExpression.boolean_operator?("not"))
    refute(Expression::LogicalExpression.boolean_operator?("=="))
    refute(Expression::LogicalExpression.boolean_operator?("contains"))
    refute(Expression::LogicalExpression.boolean_operator?("foo"))
  end

  def test_basic_parsing
    result = Expression::LogicalExpression.parse("true and false", @ss, @cache)
    assert_instance_of(Condition, result)

    result = Expression::LogicalExpression.parse("a or b", @ss, @cache)
    assert_instance_of(Condition, result)
  end

  def test_parsing_with_different_expressions
    # Test with simple variable expressions
    result = Expression::LogicalExpression.parse("var1 and var2", @ss, @cache)
    assert_instance_of(Condition, result)

    # Test with comparison expressions
    result = Expression::LogicalExpression.parse("a == 1 and b != 2", @ss, @cache)
    assert_instance_of(Condition, result)
  end

  def test_parsing_complex_expressions
    # Test with nested logical expressions
    result = Expression::LogicalExpression.parse("a and b or c", @ss, @cache)
    assert_instance_of(Condition, result)

    result = Expression::LogicalExpression.parse("a or b and c", @ss, @cache)
    assert_instance_of(Condition, result)
  end

  def test_parsing_parenthesized_expressions
    result = Expression::LogicalExpression.parse("(a and b) or c", @ss, @cache)
    assert_instance_of(Condition, result)

    result = Expression::LogicalExpression.parse("a and (b or c)", @ss, @cache)
    assert_instance_of(Condition, result)

    # Test with complex expressions
    result = Expression::LogicalExpression.parse("(a or b) and (c or d)", @ss, @cache)
    assert_instance_of(Condition, result)
  end

  def test_evaluation_of_parsed_expressions
    context = Liquid::Context.new(
      "a" => true,
      "b" => false,
      "c" => true,
      "d" => false,
    )

    # Test simple logical expressions
    expr = Expression::LogicalExpression.parse("a and c", @ss, @cache)
    assert_equal(true, expr.evaluate(context))

    expr = Expression::LogicalExpression.parse("a and b", @ss, @cache)
    assert_equal(false, expr.evaluate(context))

    expr = Expression::LogicalExpression.parse("b or c", @ss, @cache)
    assert_equal(true, expr.evaluate(context))

    expr = Expression::LogicalExpression.parse("b or d", @ss, @cache)
    assert_equal(false, expr.evaluate(context))
  end

  def test_evaluation_of_complex_expressions
    context = Liquid::Context.new(
      "a" => true,
      "b" => false,
      "c" => true,
      "d" => false,
    )

    # Test complex logical expressions
    expr = Expression::LogicalExpression.parse("a and b or c", @ss, @cache)
    assert_equal(true, expr.evaluate(context))
  end

  def test_evaluation_of_parenthesized_expressions
    context = Liquid::Context.new(
      "a" => true,
      "b" => false,
      "c" => true,
      "d" => false,
    )

    expr = Expression::LogicalExpression.parse("a and (b or d)", @ss, @cache)
    assert_equal(false, expr.evaluate(context))

    expr = Expression::LogicalExpression.parse("(a or b) and (c or d)", @ss, @cache)
    assert_equal(true, expr.evaluate(context))

    expr = Expression::LogicalExpression.parse("(a or b) and (b or d)", @ss, @cache)
    assert_equal(false, expr.evaluate(context))
  end

  def test_precedence_rules
    context = Liquid::Context.new(
      "a" => true,
      "b" => false,
      "c" => true,
    )

    # Test precedence rules (AND has higher precedence than OR)
    # This should be interpreted as: a and (b or c)
    expr1 = Expression::LogicalExpression.parse("a and b or c", @ss, @cache)
    assert_equal(true, expr1.evaluate(context))

    # Change context to make the expressions evaluate differently
    context = Liquid::Context.new(
      "a" => false,
      "b" => false,
      "c" => true,
    )

    # With these values, "a and (b or c)" would be false
    expr1 = Expression::LogicalExpression.parse("a and b or c", @ss, @cache)
    assert_equal(false, expr1.evaluate(context))
  end

  def test_precedence_with_parentheses
    context = Liquid::Context.new(
      "a" => true,
      "b" => false,
      "c" => true,
    )

    # This should be interpreted as: (a and b) or c
    expr2 = Expression::LogicalExpression.parse("(a and b) or c", @ss, @cache)
    assert_equal(true, expr2.evaluate(context))

    # Change context to make the expressions evaluate differently
    context = Liquid::Context.new(
      "a" => false,
      "b" => false,
      "c" => true,
    )

    # But "(a and b) or c" would be true
    expr2 = Expression::LogicalExpression.parse("(a and b) or c", @ss, @cache)
    assert_equal(true, expr2.evaluate(context))
  end

  def test_integration_with_if_tag
    # Test that our expressions work properly in actual templates
    assert_template_result("true", "{% if true and true %}true{% else %}false{% endif %}")
    assert_template_result("false", "{% if true and false %}true{% else %}false{% endif %}")
    assert_template_result("true", "{% if false or true %}true{% else %}false{% endif %}")
    assert_template_result("false", "{% if false or false %}true{% else %}false{% endif %}")
  end

  def test_integration_with_parenthesized_if_tag
    # Test with parenthesized expressions
    assert_template_result("true", "{% if (true and false) or true %}true{% else %}false{% endif %}")
    assert_template_result("false", "{% if true and (false or false) %}true{% else %}false{% endif %}")
    assert_template_result("true", "{% if true and (false or true) %}true{% else %}false{% endif %}")
  end

  def test_integration_with_variables
    # Test with variables
    template = "{% if a and b %}true{% else %}false{% endif %}"
    assert_template_result("true", template, { "a" => true, "b" => true })
    assert_template_result("false", template, { "a" => true, "b" => false })

    template = "{% if a or b %}true{% else %}false{% endif %}"
    assert_template_result("true", template, { "a" => true, "b" => false })
    assert_template_result("false", template, { "a" => false, "b" => false })
  end

  def test_integration_with_parenthesized_variables
    # Test with parenthesized expressions
    template = "{% if (a and b) or c %}true{% else %}false{% endif %}"
    assert_template_result("true", template, { "a" => true, "b" => true, "c" => false })
    assert_template_result("true", template, { "a" => false, "b" => false, "c" => true })
    assert_template_result("false", template, { "a" => false, "b" => false, "c" => false })

    template = "{% if a and (b or c) %}true{% else %}false{% endif %}"
    assert_template_result("true", template, { "a" => true, "b" => true, "c" => false })
    assert_template_result("true", template, { "a" => true, "b" => false, "c" => true })
    assert_template_result("false", template, { "a" => true, "b" => false, "c" => false })
    assert_template_result("false", template, { "a" => false, "b" => true, "c" => true })
  end
end
