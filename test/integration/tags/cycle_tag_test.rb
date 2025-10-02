# frozen_string_literal: true

require 'test_helper'

class CycleTagTest < Minitest::Test
  def test_simple_cycle
    template = <<~LIQUID
      {%- cycle '1', '2', '3' -%}
      {%- cycle '1', '2', '3' -%}
      {%- cycle '1', '2', '3' -%}
    LIQUID

    assert_template_result("123", template)
  end

  def test_simple_cycle_inside_for_loop
    template = <<~LIQUID
      {%- for i in (1..3) -%}
        {% cycle '1', '2', '3' %}
      {%- endfor -%}
    LIQUID

    assert_template_result("123", template)
  end

  def test_cycle_with_variables_inside_for_loop
    template = <<~LIQUID
      {%- assign a = 1 -%}
      {%- assign b = 2 -%}
      {%- assign c = 3 -%}
      {%- for i in (1..3) -%}
        {% cycle a, b, c %}
      {%- endfor -%}
    LIQUID

    assert_template_result("123", template)
  end

  def test_cycle_tag_always_resets_cycle
    template = <<~LIQUID
      {%- assign a = "1" -%}
      {%- cycle a, "2" -%}
      {%- cycle a, "2" -%}
    LIQUID

    assert_template_result("11", template)
  end

  def test_cycle_tag_without_arguments
    error = assert_raises(Liquid::SyntaxError) do
      Template.parse("{% cycle %}")
    end

    assert_match(/Syntax Error in 'cycle' - Valid syntax: cycle \[name :\] var/, error.message)
  end

  def test_cycle_tag_with_error_mode
    # QuotedFragment is more permissive than what Parser#expression allows.
    temlate1 = "{% assign 5 = 'b' %}{% cycle .5, .4 %}"
    temlate2 = "{% cycle .5: 'a', 'b' %}"

    [:lax, :strict].each do |mode|
      with_error_mode(mode) do
        assert_template_result("b", temlate1)
        assert_template_result("a", temlate2)
      end
    end

    with_error_mode(:rigid) do
      error1 = assert_raises(Liquid::SyntaxError) { Template.parse(temlate1) }
      error2 = assert_raises(Liquid::SyntaxError) { Template.parse(temlate2) }

      expected_error = /Liquid syntax error: \[:dot, "."\] is not a valid expression/

      assert_match(expected_error, error1.message)
      assert_match(expected_error, error2.message)
    end
  end
end
