# frozen_string_literal: true

require 'test_helper'

class BooleanUnitTest < Minitest::Test
  include Liquid

  def test_simple_boolean_comparison
    template = Liquid::Template.parse("{{ 1 > 0 }}")
    assert_equal(true, template.render)

    template = Liquid::Template.parse("{{ 1 < 0 }}")
    assert_equal(false, template.render)
  end

  def test_boolean_assignment_shorthand
    template = Liquid::Template.parse("{% assign lazy_load = media_position > 1 %}{{ lazy_load }}")
    assert_equal(false, template.render("media_position" => 1))
    assert_equal(true, template.render("media_position" => 2))
  end

  def test_boolean_and_operator
    template = Liquid::Template.parse("{{ true and true }}")
    assert_equal(true, template.render)

    template = Liquid::Template.parse("{{ true and false }}")
    assert_equal(false, template.render)
  end

  def test_boolean_or_operator
    template = Liquid::Template.parse("{{ true or false }}")
    assert_equal(true, template.render)

    template = Liquid::Template.parse("{{ false or false }}")
    assert_equal(false, template.render)
  end

  def test_operator_precedence_with_parentheses
    template = Liquid::Template.parse("{{ false and (false or true) }}")
    assert_equal(false, template.render)
  end

  def test_operator_precedence_without_parentheses
    template = Liquid::Template.parse("{{ false and false or true }}")
    assert_equal(true, template.render)
  end

  def test_complex_boolean_expressions
    template = Liquid::Template.parse("{{ true and true and true }}")
    assert_equal(true, template.render)

    template = Liquid::Template.parse("{{ true and false and true }}")
    assert_equal(false, template.render)

    template = Liquid::Template.parse("{{ false or false or true }}")
    assert_equal(true, template.render)
  end

  def test_boolean_with_variables
    template = Liquid::Template.parse("{{ a and b }}")
    assert_equal(true, template.render("a" => true, "b" => true))
    assert_equal(false, template.render("a" => true, "b" => false))

    template = Liquid::Template.parse("{{ a or b }}")
    assert_equal(true, template.render("a" => false, "b" => true))
    assert_equal(false, template.render("a" => false, "b" => false))
  end

  def test_mixed_boolean_expressions
    template = Liquid::Template.parse("{{ a > b and c < d }}")
    assert_equal(true, template.render("a" => 5, "b" => 3, "c" => 2, "d" => 4))
    assert_equal(false, template.render("a" => 5, "b" => 3, "c" => 5, "d" => 4))
  end
end
