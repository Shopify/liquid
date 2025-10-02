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

  def test_cycle_with_trailing_elements
    assignments = "{% assign a = 'A' %}{% assign n = 'N' %}"

    template1 = "#{assignments}{% cycle       'a'  'b', 'c' %}"
    template2 = "#{assignments}{% cycle name: 'a'  'b', 'c' %}"
    template3 = "#{assignments}{% cycle name: 'a', 'b'  'c' %}"
    template4 = "#{assignments}{% cycle n  e: 'a', 'b', 'c' %}"
    template5 = "#{assignments}{% cycle n  e  'a', 'b', 'c' %}"

    [:lax, :strict].each do |mode|
      with_error_mode(mode) do
        assert_template_result("a", template1)
        assert_template_result("a", template2)
        assert_template_result("a", template3)
        assert_template_result("N", template4)
        assert_template_result("N", template5)
      end
    end

    with_error_mode(:rigid) do
      error1 = assert_raises(Liquid::SyntaxError) { Template.parse(template1) }
      error2 = assert_raises(Liquid::SyntaxError) { Template.parse(template2) }
      error3 = assert_raises(Liquid::SyntaxError) { Template.parse(template3) }
      error4 = assert_raises(Liquid::SyntaxError) { Template.parse(template4) }
      error5 = assert_raises(Liquid::SyntaxError) { Template.parse(template5) }

      expected_error = /Expected end_of_string but found/

      assert_match(expected_error, error1.message)
      assert_match(expected_error, error2.message)
      assert_match(expected_error, error3.message)
      assert_match(expected_error, error4.message)
      assert_match(expected_error, error5.message)
    end
  end
end
