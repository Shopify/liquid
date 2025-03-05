# frozen_string_literal: true

require 'test_helper'

class BooleanUnitTest < Minitest::Test
  include Liquid

  def test_simple_boolean_comparison
    template = Liquid::Template.parse("{{ 1 > 0 }}")
    assert_equal("true", template.render)

    template = Liquid::Template.parse("{{ 1 < 0 }}")
    assert_equal("false", template.render)
  end

  def test_boolean_assignment_shorthand
    template = Liquid::Template.parse("{% assign lazy_load = media_position > 1 %}{{ lazy_load }}")
    assert_equal("false", template.render("media_position" => 1))
    assert_equal("true", template.render("media_position" => 2))
  end

  def test_boolean_and_operator
    template = Liquid::Template.parse("{{ true and true }}")
    assert_equal("true", template.render)

    template = Liquid::Template.parse("{{ true and false }}")
    assert_equal("false", template.render)
  end

  def test_boolean_or_operator
    template = Liquid::Template.parse("{{ true or false }}")
    assert_equal("true", template.render)

    template = Liquid::Template.parse("{{ false or false }}")
    assert_equal("false", template.render)
  end

  def test_operator_precedence_with_parentheses
    template = Liquid::Template.parse("{{ false and (false or true) }}")
    assert_equal("false", template.render)
  end

  def test_operator_precedence_without_parentheses
    template = Liquid::Template.parse("{{ false and false or true }}")
    assert_equal("true", template.render)
  end

  def test_complex_boolean_expressions
    template = Liquid::Template.parse("{{ true and true and true }}")
    assert_equal("true", template.render)

    template = Liquid::Template.parse("{{ true and false and true }}")
    assert_equal("false", template.render)

    template = Liquid::Template.parse("{{ false or false or true }}")
    assert_equal("true", template.render)
  end

  def test_boolean_with_variables
    template = Liquid::Template.parse("{{ a and b }}")
    assert_equal("true", template.render("a" => true, "b" => true))
    assert_equal("false", template.render("a" => true, "b" => false))

    template = Liquid::Template.parse("{{ a or b }}")
    assert_equal("true", template.render("a" => false, "b" => true))
    assert_equal("false", template.render("a" => false, "b" => false))
  end

  def test_mixed_boolean_expressions
    template = Liquid::Template.parse("{{ a > b and c < d }}")
    assert_equal("true", template.render("a" => 5, "b" => 3, "c" => 2, "d" => 4))
    assert_equal("false", template.render("a" => 5, "b" => 3, "c" => 5, "d" => 4))
  end

  def test_equality_operators
    template = Liquid::Template.parse("{{ 1 == 1 }}")
    assert_equal("true", template.render)

    template = Liquid::Template.parse("{{ 1 != 2 }}")
    assert_equal("true", template.render)

    template = Liquid::Template.parse("{{ 'hello' == 'hello' }}")
    assert_equal("true", template.render)
  end

  def test_truthy_falsy_values
    template = Liquid::Template.parse("{% if empty_string %}truthy{% else %}falsey{% endif %}")
    assert_equal("falsey", template.render("empty_string" => ""))

    template = Liquid::Template.parse("{% if zero %}truthy{% else %}falsey{% endif %}")
    assert_equal("falsey", template.render("zero" => 0))

    template = Liquid::Template.parse("{% if text %}truthy{% else %}falsey{% endif %}")
    assert_equal("true", template.render("text" => "hello"))
  end

  def test_string_comparison_with_blank
    # Non-empty string against blank
    template = Liquid::Template.parse("{{ text != blank }}")
    assert_equal("true", template.render("text" => "hello"))

    template = Liquid::Template.parse("{{ text == blank }}")
    assert_equal("false", template.render("text" => "hello"))

    # Empty string against blank
    template = Liquid::Template.parse("{{ empty_text != blank }}")
    assert_equal("false", template.render("empty_text" => ""))

    template = Liquid::Template.parse("{{ empty_text == blank }}")
    assert_equal("true", template.render("empty_text" => ""))
  end

  def test_nil_comparison_with_blank
    template = Liquid::Template.parse("{{ nil_value != blank }}")
    assert_equal("false", template.render("nil_value" => nil))

    template = Liquid::Template.parse("{{ nil_value == blank }}")
    assert_equal("true", template.render("nil_value" => nil))

    # Undefined variable is treated as nil
    template = Liquid::Template.parse("{{ undefined != blank }}")
    assert_equal("false", template.render)

    template = Liquid::Template.parse("{{ undefined == blank }}")
    assert_equal("true", template.render)
  end

  def test_empty_collections_with_blank
    template = Liquid::Template.parse("{{ empty_array == blank }}")
    assert_equal("true", template.render("empty_array" => []))

    template = Liquid::Template.parse("{{ empty_array != blank }}")
    assert_equal("false", template.render("empty_array" => []))

    template = Liquid::Template.parse("{{ empty_hash == blank }}")
    assert_equal("true", template.render("empty_hash" => {}))

    template = Liquid::Template.parse("{{ empty_hash != blank }}")
    assert_equal("false", template.render("empty_hash" => {}))

    # Non-empty collections
    template = Liquid::Template.parse("{{ array == blank }}")
    assert_equal("false", template.render("array" => [1, 2, 3]))

    template = Liquid::Template.parse("{{ hash == blank }}")
    assert_equal("false", template.render("hash" => { "key" => "value" }))
  end

  def test_blank_in_conditional_statements
    template = Liquid::Template.parse("{% if text != blank %}not blank{% else %}is blank{% endif %}")
    assert_equal("not blank", template.render("text" => "hello"))
    assert_equal("is blank", template.render("text" => ""))

    template = Liquid::Template.parse("{% if nil_value != blank %}not blank{% else %}is blank{% endif %}")
    assert_equal("is blank", template.render("nil_value" => nil))

    template = Liquid::Template.parse("{% if array != blank %}not blank{% else %}is blank{% endif %}")
    assert_equal("not blank", template.render("array" => [1, 2, 3]))
    assert_equal("is blank", template.render("array" => []))
  end

  def test_blank_with_other_operators
    template = Liquid::Template.parse("{{ text != blank and number > 0 }}")
    assert_equal("true", template.render("text" => "hello", "number" => 5))
    assert_equal("false", template.render("text" => "", "number" => 5))
    assert_equal("false", template.render("text" => "hello", "number" => 0))

    template = Liquid::Template.parse("{{ text != blank or number > 0 }}")
    assert_equal("true", template.render("text" => "hello", "number" => 0))
    assert_equal("true", template.render("text" => "", "number" => 5))
    assert_equal("false", template.render("text" => "", "number" => 0))
  end

  def test_basic_if_else_conditions
    template = Liquid::Template.parse("{% if true %}success{% else %}failure{% endif %}")
    assert_equal("success", template.render)

    template = Liquid::Template.parse("{% if false %}failure{% else %}success{% endif %}")
    assert_equal("success", template.render)
  end

  def test_if_with_comparisons
    template = Liquid::Template.parse("{% if 10 > 5 %}greater{% else %}not greater{% endif %}")
    assert_equal("greater", template.render)

    template = Liquid::Template.parse("{% if 5 == 5 %}equal{% else %}not equal{% endif %}")
    assert_equal("equal", template.render)

    template = Liquid::Template.parse("{% if 3 < 2 %}smaller{% else %}not smaller{% endif %}")
    assert_equal("not smaller", template.render)
  end

  def test_if_with_variables
    template = Liquid::Template.parse("{% if value %}has value{% else %}no value{% endif %}")
    assert_equal("has value", template.render("value" => true))
    assert_equal("no value", template.render("value" => false))
    assert_equal("no value", template.render("value" => nil))
    assert_equal("has value", template.render("value" => "text"))
    assert_equal("no value", template.render("value" => ""))
  end

  def test_if_with_variable_comparisons
    template = Liquid::Template.parse("{% if count > 5 %}high{% else %}low{% endif %}")
    assert_equal("high", template.render("count" => 10))
    assert_equal("low", template.render("count" => 3))
  end

  def test_nested_if_conditions
    template = Liquid::Template.parse("{% if a %}{% if b %}both{% else %}a only{% endif %}{% else %}none{% endif %}")
    assert_equal("both", template.render("a" => true, "b" => true))
    assert_equal("a only", template.render("a" => true, "b" => false))
    assert_equal("none", template.render("a" => false, "b" => true))
  end

  def test_elsif_conditions
    template = Liquid::Template.parse("{% if a %}a{% elsif b %}b{% else %}c{% endif %}")
    assert_equal("a", template.render("a" => true, "b" => true))
    assert_equal("b", template.render("a" => false, "b" => true))
    assert_equal("c", template.render("a" => false, "b" => false))
  end

  def test_unless_conditions
    template = Liquid::Template.parse("{% unless a %}not a{% else %}a{% endunless %}")
    assert_equal("a", template.render("a" => true))
    assert_equal("not a", template.render("a" => false))
  end

  def test_if_with_comparison_and_logical_operator
    template = Liquid::Template.parse("{% if a > 5 and b < 10 %}valid{% else %}invalid{% endif %}")
    assert_equal("valid", template.render("a" => 7, "b" => 8))
    assert_equal("invalid", template.render("a" => 3, "b" => 8))
    assert_equal("invalid", template.render("a" => 7, "b" => 12))
  end

  # Basic nil rendering tests
  def test_nil_renders_as_empty_string
    template = Liquid::Template.parse("{{ nil }}")
    assert_equal("", template.render)
  end

  def test_nil_in_assigned_variable_renders_as_empty_string
    template = Liquid::Template.parse("{% assign x = nil %}{{ x }}")
    assert_equal("", template.render)
  end

  # Nil comparison tests
  def test_nil_equals_nil
    template = Liquid::Template.parse("{{ nil == nil }}")
    assert_equal("true", template.render)
  end

  def test_nil_not_equals_nil
    template = Liquid::Template.parse("{{ nil != nil }}")
    assert_equal("false", template.render)
  end

  def test_nil_not_equals_empty_string
    template = Liquid::Template.parse("{{ nil == '' }}")
    assert_equal("false", template.render)

    template = Liquid::Template.parse("{{ nil != '' }}")
    assert_equal("true", template.render)
  end

  # Variable tests with nil values
  def test_variable_with_nil_value_in_comparisons
    template = Liquid::Template.parse("{% assign x = nil %}{{ x == nil }}")
    assert_equal("true", template.render)

    template = Liquid::Template.parse("{% assign x = nil %}{{ x != nil }}")
    assert_equal("false", template.render)
  end

  def test_variable_with_nil_value_compared_to_empty_string
    template = Liquid::Template.parse("{% assign x = nil %}{{ x == '' }}")
    assert_equal("false", template.render)

    template = Liquid::Template.parse("{% assign x = nil %}{{ x != '' }}")
    assert_equal("true", template.render)
  end

  # Tests with undefined variables
  def test_undefined_variable_in_comparisons
    template = Liquid::Template.parse("{{ undefined_var == nil }}")
    assert_equal("true", template.render)

    template = Liquid::Template.parse("{{ undefined_var != nil }}")
    assert_equal("false", template.render)
  end

  def test_undefined_variable_compared_to_empty_string
    template = Liquid::Template.parse("{{ undefined_var == '' }}")
    assert_equal("false", template.render)

    template = Liquid::Template.parse("{{ undefined_var != '' }}")
    assert_equal("true", template.render)
  end

  # Tests with boolean values
  def test_boolean_variable_in_comparisons
    template = Liquid::Template.parse("{% assign t = true %}{{ t == true }}")
    assert_equal("true", template.render)

    template = Liquid::Template.parse("{% assign f = false %}{{ f == false }}")
    assert_equal("true", template.render)
  end

  def test_boolean_variable_compared_to_nil
    template = Liquid::Template.parse("{% assign t = true %}{{ t == nil }}")
    assert_equal("false", template.render)

    template = Liquid::Template.parse("{% assign f = false %}{{ f == nil }}")
    assert_equal("false", template.render)

    template = Liquid::Template.parse("{% assign f = false %}{{ f != nil }}")
    assert_equal("true", template.render)
  end

  # Mixed comparison tests
  def test_nil_and_undefined_variables_in_boolean_expressions
    template = Liquid::Template.parse("{% assign x = nil %}{{ x == undefined_var }}")
    assert_equal("true", template.render)

    template = Liquid::Template.parse("{% assign x = nil %}{{ x != undefined_var }}")
    assert_equal("false", template.render)
  end

  def test_nil_variable_in_and_expression
    template = Liquid::Template.parse("{% assign x = nil %}{{ x and true }}")
    assert_equal("false", template.render)
  end

  def test_nil_literal_in_or_expression
    template = Liquid::Template.parse("{% assign x = nil %}{{ nil or true }}")
    assert_equal("true", template.render)
  end

  def test_nil_variable_in_or_expression
    template = Liquid::Template.parse("{% assign x = nil %}{{ x or false }}")
    assert_equal("false", template.render)
  end
end
