# frozen_string_literal: true

require 'test_helper'

class InfixOperatorsUnitTest < Minitest::Test
  include Liquid

  def test_addition_operator
    # Filter syntax
    filter_template = Liquid::Template.parse("{{ num | plus: 3 }}")
    # Infix syntax
    infix_template = Liquid::Template.parse("{{ num + 3 }}")

    assert_equal(filter_template.render("num" => 5), infix_template.render("num" => 5))
    assert_equal("8", infix_template.render("num" => 5))
  end

  def test_subtraction_operator
    # Filter syntax
    filter_template = Liquid::Template.parse("{{ num | minus: 3 }}")
    # Infix syntax
    infix_template = Liquid::Template.parse("{{ num - 3 }}")

    assert_equal(filter_template.render("num" => 5), infix_template.render("num" => 5))
    assert_equal("2", infix_template.render("num" => 5))
  end

  def test_multiplication_operator
    # Filter syntax
    filter_template = Liquid::Template.parse("{{ num | times: 3 }}")
    # Infix syntax
    infix_template = Liquid::Template.parse("{{ num * 3 }}")

    assert_equal(filter_template.render("num" => 5), infix_template.render("num" => 5))
    assert_equal("15", infix_template.render("num" => 5))
  end

  def test_division_operator
    # Filter syntax
    filter_template = Liquid::Template.parse("{{ num | divided_by: 2 }}")
    # Infix syntax
    infix_template = Liquid::Template.parse("{{ num / 2 }}")

    assert_equal(filter_template.render("num" => 10), infix_template.render("num" => 10))
    assert_equal("5", infix_template.render("num" => 10))
  end

  def test_comparison_operators
    # Greater than
    assert_equal("true", Liquid::Template.parse("{{ 5 > 3 }}").render)
    assert_equal("false", Liquid::Template.parse("{{ 3 > 5 }}").render)

    # Greater than or equal
    assert_equal("true", Liquid::Template.parse("{{ 5 >= 5 }}").render)
    assert_equal("false", Liquid::Template.parse("{{ 3 >= 5 }}").render)

    # Equal to
    assert_equal("true", Liquid::Template.parse("{{ 5 == 5 }}").render)
    assert_equal("false", Liquid::Template.parse("{{ 3 == 5 }}").render)

    # Less than or equal
    assert_equal("true", Liquid::Template.parse("{{ 5 <= 5 }}").render)
    assert_equal("false", Liquid::Template.parse("{{ 6 <= 5 }}").render)

    # Less than
    assert_equal("true", Liquid::Template.parse("{{ 3 < 5 }}").render)
    assert_equal("false", Liquid::Template.parse("{{ 5 < 3 }}").render)
  end

  def test_logical_operators
    # AND operator
    assert_equal("true", Liquid::Template.parse("{{ true && true }}").render)
    assert_equal("false", Liquid::Template.parse("{{ true && false }}").render)

    # OR operator
    assert_equal("true", Liquid::Template.parse("{{ true || false }}").render)
    assert_equal("false", Liquid::Template.parse("{{ false || false }}").render)
  end

  def test_xor_operator
    assert_equal("true", Liquid::Template.parse("{{ true ^ false }}").render)
    assert_equal("false", Liquid::Template.parse("{{ true ^ true }}").render)
    assert_equal("false", Liquid::Template.parse("{{ false ^ false }}").render)
  end

  def test_operator_precedence
    # (10 - 2) * 3 = 24
    assert_equal("24", Liquid::Template.parse("{{ (10 - 2) * 3 }}").render)
    # 10 - (2 * 3) = 4
    assert_equal("4", Liquid::Template.parse("{{ 10 - (2 * 3) }}").render)
    # Without parentheses, multiplication has higher precedence
    # 10 - 2 * 3 = 10 - 6 = 4
    assert_equal("4", Liquid::Template.parse("{{ 10 - 2 * 3 }}").render)
  end

  def test_complex_expressions
    # Multiple operations
    assert_equal("9", Liquid::Template.parse("{{ 3 + 2 * 3 }}").render)
    assert_equal("15", Liquid::Template.parse("{{ (3 + 2) * 3 }}").render)

    # Mixed arithmetic and comparison
    assert_equal("true", Liquid::Template.parse("{{ 3 + 2 > 4 }}").render)
    assert_equal("false", Liquid::Template.parse("{{ 3 + 2 < 4 }}").render)

    # Mixed arithmetic and logical
    assert_equal("true", Liquid::Template.parse("{{ 3 + 2 > 4 && 10 / 2 == 5 }}").render)
  end

  def test_combined_operations
    # In the proposed example
    infix_template = Liquid::Template.parse("{% assign media_count = media_count - variant_images.size + 1 %}")
    filter_template = Liquid::Template.parse("{% assign media_count = media_count | minus: variant_images.size | plus: 1 %}")

    # Check that both templates have the same effect
    context1 = Context.new("media_count" => 10, "variant_images" => [1, 2, 3])
    context2 = Context.new("media_count" => 10, "variant_images" => [1, 2, 3])

    infix_template.render(context1)
    filter_template.render(context2)

    assert_equal(context1["media_count"], context2["media_count"])
    assert_equal(8, context1["media_count"])
  end

  def test_with_variables
    template = Liquid::Template.parse("{{ a + b * c }}")
    assert_equal("11", template.render("a" => 5, "b" => 2, "c" => 3))

    template = Liquid::Template.parse("{{ (a + b) * c }}")
    assert_equal("21", template.render("a" => 5, "b" => 2, "c" => 3))
  end

  def test_chained_comparisons
    template = Liquid::Template.parse("{{ a < b && b < c }}")
    assert_equal("true", template.render("a" => 1, "b" => 5, "c" => 10))
    assert_equal("false", template.render("a" => 1, "b" => 15, "c" => 10))
  end
end
