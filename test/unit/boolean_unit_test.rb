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

  def test_equality_operators_with_integer_literals
    assert_expression("1", "1")
    assert_expression("1 == 1", "true")
    assert_expression("1 != 1", "false")
    assert_expression("1 == 2", "false")
    assert_expression("1 != 2", "true")
  end

  def test_equality_operators_with_stirng_literals
    assert_expression("'hello'", "hello")
    assert_expression("'hello' == 'hello'", "true")
    assert_expression("'hello' != 'hello'", "false")
    assert_expression("'hello' == 'world'", "false")
    assert_expression("'hello' != 'world'", "true")
  end

  def test_equality_operators_with_float_literals
    assert_expression("1.5", "1.5")
    assert_expression("1.5 == 1.5", "true")
    assert_expression("1.5 != 1.5", "false")
    assert_expression("1.5 == 2.5", "false")
    assert_expression("1.5 != 2.5", "true")
  end

  def test_equality_operators_with_nil_literals
    assert_expression("nil", "")
    assert_expression("nil == nil", "true")
    assert_expression("nil != nil", "false")
    assert_expression("null == nil", "true")
    assert_expression("null != nil", "false")
  end

  def test_equality_operators_with_boolean_literals
    assert_expression("true", "true")
    assert_expression("false", "false")
    assert_expression("true == true", "true")
    assert_expression("true != true", "false")
    assert_expression("false == false", "true")
    assert_expression("false != false", "false")
    assert_expression("true == false", "false")
    assert_expression("true != false", "true")
  end

  def test_equality_operators_with_empty_literals
    assert_expression("empty", "")
    assert_expression("empty == ''", "true")
    assert_expression("empty == empty", "true")
    assert_expression("empty != empty", "false")
    assert_expression("blank == blank", "true")
    assert_expression("blank != blank", "false")
    assert_expression("empty == blank", "true")
    assert_expression("empty != blank", "false")
  end

  def test_nil_renders_as_empty_string
    # No parity needed here. This is to ensure expressions rendered with {{ }}
    # will still render as an empty string to preserve pre-existing behavior.
    assert_expression("nil", "")
    assert_expression("x", "", { "x" => nil })
    assert_parity_scenario(:expression, "hello {{ x }}", "hello ", { "x" => nil })
  end

  def test_nil_comparison_with_blank
    assert_parity("nil_value == blank", "false")
    assert_parity("nil_value != blank", "true")
    assert_parity("undefined != blank", "true")
    assert_parity("undefined == blank", "false")
  end

  def test_if_with_variables
    assert_parity("value", "true",  { "value" => true })
    assert_parity("value", "false", { "value" => false })
  end

  def test_nil_variable_in_and_expression
    assert_condition("x and true", "false", { "x" => nil })
    assert_condition("true and x", "false", { "x" => nil })

    assert_expression("x and true", "",     { "x" => nil })
    assert_expression("true and x", "",     { "x" => nil })
  end

  def test_boolean_variable_in_and_expression
    assert_parity("true and x", "false", { "x" => false })
    assert_parity("x and true", "false", { "x" => false })

    assert_parity("true and x", "true",  { "x" => true })
    assert_parity("x and true", "true",  { "x" => true })

    assert_parity("true or x", "true",   { "x" => false })
    assert_parity("x or true", "true",   { "x" => false })

    assert_parity("true or x", "true",   { "x" => true })
    assert_parity("x or true", "true",   { "x" => true })
  end

  def test_multi_variable_boolean_nil_and_expression
    assert_condition("x and y", "false", { "x" => nil, "y" => true })
    assert_condition("y and x", "false", { "x" => true, "y" => nil })

    assert_expression("x and y", "",     { "x" => nil, "y" => true })
    assert_expression("y and x", "",     { "x" => true, "y" => nil })
  end

  def test_multi_truthy_variables_and_expressions
    assert_condition("x or y", "true",   { "x" => nil, "y" => "hello" })
    assert_condition("y or x", "true",   { "x" => "hello", "y" => nil })

    assert_expression("x or y", "hello", { "x" => nil, "y" => "hello" })
    assert_expression("y or x", "hello", { "x" => "hello", "y" => nil })
  end

  def test_multi_variable_boolean_nil_or_expression
    assert_parity("x or y", "true", { "x" => nil, "y" => true })
    assert_parity("y or x", "true", { "x" => true, "y" => nil })
  end

  def test_links_not_blank_with_drop_returns_true_for_all_cases
    link = LinkDrop.new(
      levels: 0,
      links: [
        LinkDrop.new(levels: 1, links: [], title: "About", type: "page_link", url: "/pages/about"),
        LinkDrop.new(levels: 1, links: [], title: "Contact", type: "page_link", url: "/pages/contact"),
      ],
      title: "Main Menu",
      type: "menu",
      url: nil,
    )

    template = <<~LIQUID
      {%- if link.links != blank -%}
        true
      {%- else -%}
        false
      {%- endif -%}
    LIQUID

    act_output = Liquid::Template.parse(template).render({ "link" => link })
    assert_equal("true", act_output)

    act_output = Liquid::Template.parse(template).render({ "link" => link.tap { |l| l.links = [] } })
    assert_equal("true", act_output)

    act_output = Liquid::Template.parse(template).render({ "link" => link.tap { |l| l.links = nil } })
    assert_equal("true", act_output)

    act_output = Liquid::Template.parse(template).render({ "link" => LinkDrop.new })
    assert_equal("true", act_output)
  end

  def test_links_truthy_with_drop_returns_false_for_nil_and_empty_drop
    link = LinkDrop.new(
      levels: 0,
      links: [
        LinkDrop.new(levels: 1, links: [], title: "About", type: "page_link", url: "/pages/about"),
        LinkDrop.new(levels: 1, links: [], title: "Contact", type: "page_link", url: "/pages/contact"),
      ],
      title: "Main Menu",
      type: "menu",
      url: nil,
    )

    template = <<~LIQUID
      {%- if link.links -%}
        true
      {%- else -%}
        false
      {%- endif -%}
    LIQUID

    act_output = Liquid::Template.parse(template).render({ "link" => link })
    assert_equal("true", act_output)

    act_output = Liquid::Template.parse(template).render({ "link" => link.tap { |l| l.links = [] } })
    assert_equal("true", act_output)

    act_output = Liquid::Template.parse(template).render({ "link" => link.tap { |l| l.links = nil } })
    assert_equal("false", act_output)

    act_output = Liquid::Template.parse(template).render({ "link" => {} })
    assert_equal("false", act_output)
  end

  def test_links_not_blank_with_hash_returns_true_for_all_cases
    link = {
      "levels" => 0,
      "links" => [
        {
          "levels" => 1,
          "links" => [],
          "title" => { "text" => "About" },
          "type" => "page_link",
          "url" => "/pages/about",
        },
        {
          "levels" => 1,
          "links" => [],
          "title" => { "text" => "Contact" },
          "type" => "page_link",
          "url" => "/pages/contact",
        },
      ],
      "title" => { "text" => "Main Menu" },
      "type" => "menu",
      "url" => nil,
    }

    template = <<~LIQUID
      {%- if link.links != blank -%}
        true
      {%- else -%}
        false
      {%- endif -%}
    LIQUID

    act_output = Liquid::Template.parse(template).render({ "link" => link })
    assert_equal("true", act_output)

    act_output = Liquid::Template.parse(template).render({ "link" => { **link, "links" => [] } })
    assert_equal("true", act_output)

    act_output = Liquid::Template.parse(template).render({ "link" => { **link, "links" => nil } })
    assert_equal("true", act_output)

    act_output = Liquid::Template.parse(template).render({ "link" => {} })
    assert_equal("true", act_output)
  end

  def test_links_truthy_with_hash_returns_false_for_nil_and_empty_hash
    link = {
      "levels" => 0,
      "links" => [
        {
          "levels" => 1,
          "links" => [],
          "title" => { "text" => "About" },
          "type" => "page_link",
          "url" => "/pages/about",
        },
        {
          "levels" => 1,
          "links" => [],
          "title" => { "text" => "Contact" },
          "type" => "page_link",
          "url" => "/pages/contact",
        },
      ],
      "title" => { "text" => "Main Menu" },
      "type" => "menu",
      "url" => nil,
    }

    template = <<~LIQUID
      {%- if link.links -%}
        true
      {%- else -%}
        false
      {%- endif -%}
    LIQUID

    act_output = Liquid::Template.parse(template).render({ "link" => link })
    assert_equal("true", act_output)

    act_output = Liquid::Template.parse(template).render({ "link" => { **link, "links" => [] } })
    assert_equal("true", act_output)

    act_output = Liquid::Template.parse(template).render({ "link" => { **link, "links" => nil } })
    assert_equal("false", act_output)

    act_output = Liquid::Template.parse(template).render({ "link" => {} })
    assert_equal("false", act_output)
  end

  def test_conditions_with_boolean_operators_without_whitespace_around_operator
    template = <<~LIQUID
      <option variant_id="{{ variant.id }}" {% if current_variant.id==variant.id %}selected{%- endif -%}>{{ variant.title }}</option>
    LIQUID

    context = {
      "variant" => {
        "id" => 420,
        "title" => "Default Title",
      },
      "current_variant" => {
        "id" => 420,
      },
    }

    # Expected output
    # Note: Ideally we would like the whitespace around the boolean operator to be optional.
    # So the more correct expected output would be:
    #
    # <option variant_id="420" selected>Default Title</option>
    #
    # However, the existing behaviour in liquid-ruby is that the whitespace is required around the boolean operator.
    expected_lax_output = <<~HTML
      <option variant_id="420" >Default Title</option>
    HTML

    expected_strict_output = <<~HTML
      <option variant_id="420" selected>Default Title</option>
    HTML

    # This bugged output only happens in lax mode.
    prev_error_mode = Liquid::Environment.default.error_mode
    Liquid::Environment.default.error_mode = :lax
    actual_lax_output = Liquid::Template.parse(template).render(context)
    Liquid::Environment.default.error_mode = prev_error_mode

    actual_strict_output = Liquid::Template.parse(template).render(context)

    assert_equal(expected_lax_output.delete("\n"), actual_lax_output.delete("\n"))
    assert_equal(expected_strict_output.delete("\n"), actual_strict_output.delete("\n"))
  end

  # TESTING INCORRECT BEHAVIOUR OF LIQUID-RUBY
  # If liquid-vm fails this test, we should change it.
  def test_boolean_conditional_with_json_filter
    # Define the Liquid template to test
    template = <<~LIQUID
      {{ template.name == 'index' | json }}
    LIQUID

    # Define the context for the template where the template name is 'index'
    context = {
      "template" => {
        "name" => "product",
      },
    }

    # Expected output
    # Note: I dont know what is the correct output here but this is the liquid-ruby 'main' output.
    #
    # It feels incorrect but I dont know whats better
    expected_output = "product"

    # Render the template with the context
    actual_parsed_template = Liquid::Template.parse(template)
    actual_output = actual_parsed_template.render(context)

    # Assert that the actual output matches the expected output
    assert_equal(expected_output, actual_output.strip)
  end

  private

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

  class LinkDrop < Liquid::Drop
    attr_accessor :levels, :links, :title, :type, :url

    def initialize(levels: nil, links: nil, title: nil, type: nil, url: nil)
      super()

      @levels = levels
      @links = links
      @title = title
      @type = type
      @url = url
    end
  end
end
