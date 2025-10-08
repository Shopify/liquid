# frozen_string_literal: true

require 'test_helper'

class RigidModeUnitTest < Minitest::Test
  include Liquid

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

    error = assert_raises(SyntaxError) { rigid_parse(template) }

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

    error = assert_raises(SyntaxError) { rigid_parse(template) }

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

    error = assert_raises(SyntaxError) { rigid_parse(template) }

    assert_match(/Unexpected character =/, error.message)
  end

  def test_include_template_with_invalid_expression
    template = "{% include foo=>bar %}"

    refute_nil(lax_parse(template))
    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) { rigid_parse(template) }

    assert_match(/Unexpected character =/, error.message)
  end

  def test_include_with_invalid_expression
    template = '{% include "snippet" with foo=>bar %}'

    refute_nil(lax_parse(template))
    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) { rigid_parse(template) }

    assert_match(/Unexpected character =/, error.message)
  end

  def test_include_attribute_with_invalid_expression
    template = '{% include "snippet", key: foo=>bar %}'

    refute_nil(lax_parse(template))
    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) { rigid_parse(template) }

    assert_match(/Unexpected character =/, error.message)
  end

  def test_render_with_invalid_expression
    template = '{% render "snippet" with foo=>bar %}'

    refute_nil(lax_parse(template))
    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) { rigid_parse(template) }

    assert_match(/Unexpected character =/, error.message)
  end

  def test_render_attribute_with_invalid_expression
    template = '{% render "snippet", key: foo=>bar %}'

    refute_nil(lax_parse(template))
    refute_nil(strict_parse(template))

    error = assert_raises(SyntaxError) { rigid_parse(template) }

    assert_match(/Unexpected character =/, error.message)
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
