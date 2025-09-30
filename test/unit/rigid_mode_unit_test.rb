# frozen_string_literal: true

require 'test_helper'

class RigidModeUnitTest < Minitest::Test
  include Liquid

  def test_direct_parse_expression_comparison
    test_cases = [
      'foo bar',
      'user.name first',
      'items[0] next',
      'products[0].name extra',
    ]

    test_cases.each do |expr|
      ctx_strict = ParseContext.new(environment: strict_env)
      result = ctx_strict.parse_expression(expr)
      refute_nil(result, "Strict mode should parse '#{expr}'")

      ctx_rigid = ParseContext.new(environment: rigid_env)
      error = assert_raises(SyntaxError) do
        ctx_rigid.parse_expression(expr)
      end

      assert_match(/Expected end_of_string but found id/, error.message)
    end
  end

  def test_comparison_strict_vs_rigid_with_space_separated_lookups
    expr = 'product title'

    ctx_lax = ParseContext.new(environment: lax_env)
    result_lax = ctx_lax.parse_expression(expr)
    assert_equal('product', result_lax.name)
    assert_equal(['title'], result_lax.lookups)

    ctx_strict = ParseContext.new(environment: strict_env)
    result_strict = ctx_strict.parse_expression(expr)
    assert_equal('product', result_strict.name)
    assert_equal(['title'], result_strict.lookups)

    ctx_rigid = ParseContext.new(environment: rigid_env)
    assert_raises(SyntaxError) do
      ctx_rigid.parse_expression(expr)
    end
  end

  def test_tablerow_limit_with_invalid_expression
    template = <<~LIQUID
      {% tablerow i in (1..10) limit: foo=>bar %}{{ i }}{% endtablerow %}
    LIQUID

    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_tablerow_offset_with_invalid_expression
    template = <<~LIQUID
      {% tablerow i in (1..10) offset: foo=>bar %}{{ i }}{% endtablerow %}
    LIQUID

    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_cycle_name_with_invalid_expression
    template = <<~LIQUID
      {% for i in (1..3) %}
        {% cycle foo=>bar: "a", "b" %}
      {% endfor %}
    LIQUID

    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_cycle_variable_with_invalid_expression
    template = <<~LIQUID
      {% for i in (1..3) %}
        {% cycle foo=>bar, "a", "b" %}
      {% endfor %}
    LIQUID

    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_case_with_invalid_expression
    template = <<~LIQUID
      {% case foo=>bar %}
        {% when 1 %}
          one
      {% endcase %}
    LIQUID

    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_include_template_with_invalid_expression
    template = "{% include foo=>bar %}"

    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_include_with_invalid_expression
    template = '{% include "snippet" with foo=>bar %}'

    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_include_attribute_with_invalid_expression
    template = '{% include "snippet", key: foo=>bar %}'

    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_render_with_invalid_expression
    template = '{% render "snippet" with foo=>bar %}'

    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_render_attribute_with_invalid_expression
    template = '{% render "snippet", key: foo=>bar %}'

    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_valid_expressions_work_in_rigid_mode
    test_cases = {
      '{{ foo }}' => { 'foo' => 'bar' },
      '{{ foo.bar }}' => { 'foo' => { 'bar' => 'baz' } },
      '{{ items[0] }}' => { 'items' => ['first', 'second'] },
      '{{ product.variants[0].title }}' => { 'product' => { 'variants' => [{ 'title' => 'Small' }] } },
      '{{ "hello" }}' => {},
      '{{ 42 }}' => {},
      '{{ 3.14 }}' => {},
    }

    test_cases.each do |template_str, data|
      t = rigid_parse(template_str)
      result = t.render(data)
      assert(result.is_a?(String), "Should render successfully for '#{template_str}'")
    end
  end

  def test_rigid_mode_with_ranges
    template = <<~LIQUID
      {% for i in (1..3) %}{{ i }}{% endfor %}
    LIQUID

    t = rigid_parse(template)
    result = t.render
    assert_equal("123\n", result)
  end

  def test_rigid_mode_with_variable_ranges
    template = <<~LIQUID
      {% for i in (start..end) %}{{ i }}{% endfor %}
    LIQUID

    t = rigid_parse(template)
    result = t.render({ 'start' => 1, 'end' => 3 })
    assert_equal("123\n", result)
  end

  def test_rigid_mode_valid_filters
    template = <<~LIQUID
      {{ "hello" | upcase | prepend: "Say: " }}
    LIQUID

    t = rigid_parse(template)
    result = t.render
    assert_equal("Say: HELLO\n", result)
  end

  def test_rigid_mode_valid_filter_with_correct_variable_args
    template = <<~LIQUID
      {{ "hello" | append: world.name }}
    LIQUID

    t = rigid_parse(template)
    result = t.render({ 'world' => { 'name' => ' world' } })
    assert_equal("hello world\n", result)
  end

  def test_empty_expression_handling
    ctx_rigid = ParseContext.new(environment: rigid_env)
    result = ctx_rigid.parse_expression('')
    assert_nil(result)

    result = ctx_rigid.parse_expression('   ')
    assert_nil(result)
  end

  private

  def rigid_parse(source)
    Template.parse(source, environment: rigid_env)
  end

  def strict_parse(source)
    Template.parse(source, environment: strict_env)
  end

  def lax_env
    Environment.build(error_mode: :lax)
  end

  def rigid_env
    Environment.build(error_mode: :rigid)
  end

  def strict_env
    Environment.build(error_mode: :strict)
  end
end
