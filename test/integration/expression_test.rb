# frozen_string_literal: true

require 'test_helper'

class ExpressionTest < Minitest::Test
  def test_keyword_literals
    assert_template_result("true", "{{ true }}")
    assert_expression_result(true, "true")
  end

  def test_string
    assert_template_result("single quoted", "{{'single quoted'}}")
    assert_template_result("double quoted", '{{"double quoted"}}')
    assert_template_result("spaced", "{{ 'spaced' }}")
    assert_template_result("spaced2", "{{ 'spaced2' }}")
  end

  def test_int
    assert_template_result("456", "{{ 456 }}")
    assert_expression_result(123, "123")
    assert_expression_result(12, "012")
  end

  def test_float
    assert_template_result("2.5", "{{ 2.5 }}")
    assert_expression_result(1.5, "1.5")
  end

  def test_range
    assert_template_result("3..4", "{{ ( 3 .. 4 ) }}")
    assert_expression_result(1..2, "(1..2)")

    assert_match_syntax_error(
      "Liquid syntax error (line 1): Invalid expression type 'false' in range expression",
      "{{ (false..true) }}"
    )
    assert_match_syntax_error(
      "Liquid syntax error (line 1): Invalid expression type '(1..2)' in range expression",
      "{{ ((1..2)..3) }}"
    )
  end

  private

  def assert_expression_result(expect, markup, **assigns)
    liquid = "{% if expect == #{markup} %}pass{% else %}got {{ #{markup} }}{% endif %}"
    assert_template_result("pass", liquid, { "expect" => expect, **assigns })
  end
end
