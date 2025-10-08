# frozen_string_literal: true

require 'test_helper'

class RigidModeUnitTest < Minitest::Test
  include Liquid

  def test_direct_parse_expression_comparison
    test_cases = [
      '{{ foo bar }}',
      '{{ user.name first }}',
      '{{ items[0] next }}',
      '{{ products[0].name extra }}',
    ]

    test_cases.each do |template|
      refute_nil(lax_parse(template))
      assert_raises(SyntaxError) { strict_parse(template) }
      assert_raises(SyntaxError) { rigid_parse(template) }
    end
  end

  def test_comparison_strict_vs_rigid_with_space_separated_lookups
    template = '{{ product title }}'

    output = lax_parse(template).render({ 'product' => { 'title' => 'Snow' } })
    assert_equal('{"title"=>"Snow"}', output)

    assert_raises(SyntaxError) { strict_parse(template) }
    assert_raises(SyntaxError) { rigid_parse(template) }
  end

  def test_tablerow_limit_with_invalid_expression
    skip

    template = <<~LIQUID
      {% tablerow i in (1..10) limit: foo=>bar %}{{ i }}{% endtablerow %}
    LIQUID

    refute_nil(lax_parse(template))
    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_tablerow_offset_with_invalid_expression
    skip

    template = <<~LIQUID
      {% tablerow i in (1..10) offset: foo=>bar %}{{ i }}{% endtablerow %}
    LIQUID

    refute_nil(lax_parse(template))
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

    refute_nil(lax_parse(template))
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

    refute_nil(lax_parse(template))
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

    refute_nil(lax_parse(template))
    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_include_template_with_invalid_expression
    template = "{% include foo=>bar %}"

    refute_nil(lax_parse(template))
    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_include_with_invalid_expression
    template = '{% include "snippet" with foo=>bar %}'

    refute_nil(lax_parse(template))
    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_include_attribute_with_invalid_expression
    template = '{% include "snippet", key: foo=>bar %}'

    refute_nil(lax_parse(template))
    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_render_with_invalid_expression
    template = '{% render "snippet" with foo=>bar %}'

    refute_nil(lax_parse(template))
    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) do
      rigid_parse(template)
    end
    assert_match(/Unexpected character =/, error.message)
  end

  def test_render_attribute_with_invalid_expression
    template = '{% render "snippet", key: foo=>bar %}'

    refute_nil(lax_parse(template))
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
      lax_result = lax_parse(template_str).render(data)
      assert(lax_result.is_a?(String), "Lax mode should render '#{template_str}'")

      strict_result = strict_parse(template_str).render(data)
      assert(strict_result.is_a?(String), "Strict mode should render '#{template_str}'")

      rigid_result = rigid_parse(template_str).render(data)
      assert(rigid_result.is_a?(String), "Rigid mode should render '#{template_str}'")
    end
  end

  def test_rigid_mode_with_ranges
    template = <<~LIQUID
      {% for i in (1..3) %}{{ i }}{% endfor %}
    LIQUID

    lax_result = lax_parse(template).render
    assert_equal("123\n", lax_result)

    strict_result = strict_parse(template).render
    assert_equal("123\n", strict_result)

    rigid_result = rigid_parse(template).render
    assert_equal("123\n", rigid_result)
  end

  def test_rigid_mode_with_variable_ranges
    template = <<~LIQUID
      {% for i in (start..end) %}{{ i }}{% endfor %}
    LIQUID

    data = { 'start' => 1, 'end' => 3 }

    lax_result = lax_parse(template).render(data)
    assert_equal("123\n", lax_result)

    strict_result = strict_parse(template).render(data)
    assert_equal("123\n", strict_result)

    rigid_result = rigid_parse(template).render(data)
    assert_equal("123\n", rigid_result)
  end

  def test_rigid_mode_valid_filters
    template = <<~LIQUID
      {{ "hello" | upcase | prepend: "Say: " }}
    LIQUID

    lax_result = lax_parse(template).render
    assert_equal("Say: HELLO\n", lax_result)

    strict_result = strict_parse(template).render
    assert_equal("Say: HELLO\n", strict_result)

    rigid_result = rigid_parse(template).render
    assert_equal("Say: HELLO\n", rigid_result)
  end

  def test_rigid_mode_valid_filter_with_correct_variable_args
    template = <<~LIQUID
      {{ "hello" | append: world.name }}
    LIQUID

    data = { 'world' => { 'name' => ' world' } }

    lax_result = lax_parse(template).render(data)
    assert_equal("hello world\n", lax_result)

    strict_result = strict_parse(template).render(data)
    assert_equal("hello world\n", strict_result)

    rigid_result = rigid_parse(template).render(data)
    assert_equal("hello world\n", rigid_result)
  end

  def test_empty_expression_handling
    ctx_rigid = ParseContext.new(environment: rigid)

    assert_nil(ctx_rigid.parse_expression('', safe: true))
    assert_nil(ctx_rigid.parse_expression('   ', safe: true))
  end

  private

  def rigid_parse(source)
    Template.parse(source, environment: rigid)
  end

  def strict_parse(source)
    Template.parse(source, environment: strict)
  end

  def lax_parse(source)
    Template.parse(source, environment: lax)
  end

  def lax
    Environment.build(error_mode: :lax)
  end

  def rigid
    Environment.build(error_mode: :rigid)
  end

  def strict
    Environment.build(error_mode: :strict)
  end
end
