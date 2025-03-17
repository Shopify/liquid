# frozen_string_literal: true

require 'test_helper'

class RangeUnitTest < Minitest::Test
  include Liquid

  def test_basic_range_creation
    assert_template_result("1 2 3 4 5", "{% for i in (1..5) %}{{ i }} {% endfor %}")
  end

  def test_range_with_variables
    assert_template_result("3 4 5", "{% assign start = 3 %}{% for i in (start..5) %}{{ i }} {% endfor %}")
    assert_template_result("1 2 3", "{% assign end = 3 %}{% for i in (1..end) %}{{ i }} {% endfor %}")
    assert_template_result("2 3 4", "{% assign start = 2 %}{% assign end = 4 %}{% for i in (start..end) %}{{ i }} {% endfor %}")
  end

  def test_range_with_whitespace
    assert_template_result("1 2 3", "{% for i in ( 1 .. 3 ) %}{{ i }} {% endfor %}")
    assert_template_result("1 2 3", "{% for i in (1 .. 3) %}{{ i }} {% endfor %}")
  end

  def test_range_with_expressions
    assert_template_result("3 4 5", "{% assign x = 1 %}{% assign start = x | plus: 2 %}{% for i in (start..5) %}{{ i }} {% endfor %}")
    assert_template_result("1 2 3", "{% assign x = 2 %}{% assign end = x | plus: 1 %}{% for i in (1..end) %}{{ i }} {% endfor %}")
  end

  def test_range_with_literals_in_iteration
    assert_template_result("1 2 3 4 5", "{% for i in (1..5) %}{{ i }} {% endfor %}")
  end

  def test_range_size_and_first_last
    assert_template_result("5", "{{ (1..5) | size }}")
    assert_template_result("1", "{{ (1..5) | first }}")
    assert_template_result("5", "{{ (1..5) | last }}")
  end

  def test_empty_ranges
    assert_template_result("", "{% for i in (5..1) %}{{ i }}{% endfor %}")
  end

  def test_ranges_in_conditionals
    assert_template_result("yes", "{% if 3 >= (1..5) %}no{% else %}yes{% endif %}")
    assert_template_result("yes", "{% if (1..5) contains 3 %}yes{% else %}no{% endif %}")
    assert_template_result("no", "{% if (1..5) contains 6 %}yes{% else %}no{% endif %}")
  end

  def test_range_with_negative_numbers
    assert_template_result("-3 -2 -1 0", "{% for i in (-3..0) %}{{ i }} {% endfor %}")
  end

  def test_range_with_floats
    # Liquid doesn't support float ranges, should either error or not iterate
    template = "{% for i in (1.5..3.5) %}{{ i }} {% endfor %}"
    # Floats are rounded down to the nearest integer
    assert_template_result("1 2 3", template)
  end

  # def test_ranges_with_calculated_endpoints
  #   assert_template_result(
  #     "3 4 5",
  #     "{% assign start = 1 %}{% assign end = 7 %}{% for i in (start | plus: 2 .. end | minus: 2) %}{{ i }} {% endfor %}",
  #   )
  # end

  def test_malformed_ranges
    # Missing start value
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse("{% for i in (..5) %}{{ i }}{% endfor %}") }
    # Missing end value
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse("{% for i in (1..) %}{{ i }}{% endfor %}") }
    # Missing both values
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse("{% for i in (..) %}{{ i }}{% endfor %}") }
    # Wrong syntax (no parentheses)
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse("{% for i in 1..5 %}{{ i }}{% endfor %}") }
    # Unbalanced parentheses
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse("{% for i in (1..5 %}{{ i }}{% endfor %}") }
    # Invalid characters in range
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse("{% for i in (#..@) %}{{ i }}{% endfor %}") }
    # Invalid range
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse("{% assign start = 1 %}{% assign end = 7 %}{% for i in (start | plus: 2 .. end | minus: 2) %}{{ i }} {% endfor %}") }
  end

  def test_ranges_with_strings_and_variables
    assert_template_result(
      "3 4 5",
      "{% assign range = (3..5) %}{% for i in range %}{{ i }} {% endfor %}",
    )
    assert_template_result(
      "4 5 6",
      "{% assign start = 4 %}{% assign range = (start..6) %}{% for i in range %}{{ i }} {% endfor %}",
    )
  end

  def test_ranges_with_limit_and_offset
    assert_template_result(
      "2 3",
      "{% for i in (1..5) limit:2 offset:1 %}{{ i }} {% endfor %}",
    )
    assert_template_result(
      "3 4 5",
      "{% for i in (1..5) offset:2 %}{{ i }} {% endfor %}",
    )
    assert_template_result(
      "1 2",
      "{% for i in (1..5) limit:2 %}{{ i }} {% endfor %}",
    )
  end

  def test_reversed_ranges
    assert_template_result(
      "5 4 3 2 1",
      "{% for i in (1..5) reversed %}{{ i }} {% endfor %}",
    )
  end

  def test_variable_ranges_with_reversed
    assert_template_result(
      "4 3 2 1",
      "{% assign num = 4 %}{% for i in (1..num) reversed %}{{ i }} {% endfor %}",
    )
  end

  def test_assigned_ranges_with_reversed
    assert_template_result(
      "5 4 3 2 1",
      "{% assign range = (1..5) %}{% for i in range reversed %}{{ i }} {% endfor %}",
    )
  end

  private

  def assert_template_result(expected, template, assigns = {})
    assert_equal(expected, Liquid::Template.parse(template).render!(assigns).strip)
  end
end
