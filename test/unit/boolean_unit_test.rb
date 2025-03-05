# frozen_string_literal: true

require 'test_helper'

class BooleanUnitTest < Minitest::Test
  include Liquid

  def test_simple_boolean_comparison
    assert_parity("1 > 0", "true")
    assert_parity("1 < 0", "false")
  end

  def test_boolean_and_operator
    assert_parity("true and true", "true")
    assert_parity("true and false", "false")
  end

  def test_boolean_or_operator
    assert_parity("true or false", "true")
    assert_parity("false or false", "false")
  end

  def test_operator_precedence
    assert_parity("false and false or true", "false")
  end

  def test_complex_boolean_expressions
    assert_parity("true and true and true", "true")
    assert_parity("true and false and true", "false")
    assert_parity("false or false or true", "true")
  end

  def test_boolean_with_variables
    assert_parity("a and b", "true", { "a" => true, "b" => true })
    assert_parity("a and b", "false", { "a" => true, "b" => false })
    assert_parity("a or b", "true", { "a" => false, "b" => true })
    assert_parity("a or b", "false", { "a" => false, "b" => false })
  end

  def test_nil_equals_nil
    assert_parity("nil == nil", "true")
  end

  def test_nil_not_equals_nil
    assert_parity("nil != nil", "false")
  end

  def test_nil_not_equals_empty_string
    assert_parity("nil == ''", "false")
    assert_parity("nil != ''", "true")
  end

  def test_undefined_variable_in_comparisons
    assert_parity("undefined_var == nil", "true")
    assert_parity("undefined_var != nil", "false")
  end

  def test_undefined_variable_compared_to_empty_string
    assert_parity("undefined_var == ''", "false")
    assert_parity("undefined_var != ''", "true")
  end

  def test_boolean_variable_in_comparisons
    assert_parity("t == true", "true", { "t" => true })
    assert_parity("f == false", "true", { "f" => false })
  end

  def test_boolean_variable_compared_to_nil
    assert_parity("t == nil", "false", { "t" => true })
    assert_parity("f == nil", "false", { "f" => false })
    assert_parity("f != nil", "true", { "f" => false })
  end

  def test_nil_and_undefined_variables_in_boolean_expressions
    assert_parity("x == undefined_var", "true", { "x" => nil })
    assert_parity("x != undefined_var", "false", { "x" => nil })
  end

  def test_nil_literal_in_or_expression
    assert_parity("nil or true", "true")
  end

  def test_nil_variable_in_or_expression
    assert_parity("x or false", "false", { "x" => nil })
  end

  def test_mixed_boolean_expressions
    assert_parity("a > b and c < d", "true",  { "a" => 99, "b" => 0, "c" => 0,  "d" => 99 })
    assert_parity("a > b and c < d", "false", { "a" => 99, "b" => 0, "c" => 99, "d" => 0  })
  end

  def test_boolean_assignment_shorthand
    template = Liquid::Template.parse("{% assign lazy_load = media_position > 1 %}{{ lazy_load }}")
    assert_equal("false", template.render("media_position" => 1))
    assert_equal("true",  template.render("media_position" => 2))
  end

  def test_equality_operators
    assert_parity_todo!("1 == 1", "true")
    assert_parity_todo!("1 != 2", "true")
    assert_parity_todo!("'hello' == 'hello'", "true")
  end

  def test_nil_renders_as_empty_string
    assert_parity_todo!("nil", "false")
  end

  def test_nil_comparison_with_blank
    assert_parity("nil_value == blank", "false")
    assert_parity("nil_value != blank", "true")
    assert_parity("undefined != blank", "true")
    assert_parity("undefined == blank", "false")
  end

  def test_if_with_variables
    assert_parity_todo!("value", "true",  { "value" => true })
    assert_parity_todo!("value", "false", { "value" => false })
    assert_parity_todo!("value", "false", { "value" => nil })
    assert_parity_todo!("value", "true",  { "value" => "text" })
    assert_parity_todo!("value", "true", { "value" => "" })
  end

  def test_nil_variable_in_and_expression
    assert_parity("x and true", "false", { "x" => nil })
    assert_parity("true and x", "false", { "x" => nil })
  end

  def test_boolean_variable_in_and_expression
    assert_parity("true and x", "false", { "x" => false })
    assert_parity("x and true", "false", { "x" => false })
  end

  private

  def assert_parity_todo!(liquid_expression, expected_result, args = {})
    assert_parity_scenario(:condition, "{% if #{liquid_expression} %}true{% else %}false{% endif %}", expected_result, args)
    test_name = caller_locations(1, 1)[0].label
    puts "\e[33mTODO: parity for '#{test_name}'\e[0m"
  end

  def assert_parity(liquid_expression, expected_result, args = {})
    assert_condition(liquid_expression, expected_result, args)
    assert_expression(liquid_expression, expected_result, args)
  end

  def assert_expression(liquid_expression, expected_result, args = {})
    assert_parity_scenario(:expression, "{{ #{liquid_expression} }}", expected_result, args)
  end

  def assert_condition(liquid_condition, expected_result, args = {})
    assert_parity_scenario(:condition, "{% if #{liquid_condition} %}true{% else %}false{% endif %}", expected_result, args)
  end

  def assert_parity_scenario(kind, template, exp_output, args = {})
    act_output = Liquid::Template.parse(template).render(args)

    assert_equal(exp_output, act_output, <<~ERROR_MESSAGE)
      #{kind.to_s.capitalize} template failure:
      ---
      #{template}
      ---
      args: #{args.inspect}
    ERROR_MESSAGE
  end
end
