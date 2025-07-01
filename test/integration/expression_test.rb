# frozen_string_literal: true

require 'test_helper'
require 'lru_redux'

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
    assert_template_result("emoji🔥", "{{ 'emoji🔥' }}")
  end

  def test_int
    assert_template_result("456", "{{ 456 }}")
    assert_expression_result(123, "123")
    assert_expression_result(12, "012")
  end

  def test_float
    assert_template_result("-17.42", "{{ -17.42 }}")
    assert_template_result("2.5", "{{ 2.5 }}")
    assert_expression_result(0.0, "0.....5")
    assert_expression_result(0.0, "-0..1")
    assert_expression_result(1.5, "1.5")

    # this is a unfortunate quirky behavior of Liquid
    result = Expression.parse(".5")
    assert_kind_of(Liquid::VariableLookup, result)

    result = Expression.parse("-.5")
    assert_kind_of(Liquid::VariableLookup, result)
  end

  def test_range
    assert_template_result("3..4", "{{ ( 3 .. 4 ) }}")
    assert_expression_result(1..2, "(1..2)")

    assert_match_syntax_error(
      "Liquid syntax error (line 1): Invalid expression type 'false' in range expression",
      "{{ (false..true) }}",
    )
    assert_match_syntax_error(
      "Liquid syntax error (line 1): Invalid expression type '(1..2)' in range expression",
      "{{ ((1..2)..3) }}",
    )
  end

  def test_quirky_negative_sign_expression_markup
    result = Expression.parse("-", nil)
    assert(result.is_a?(VariableLookup))
    assert_equal("-", result.name)

    # for this template, the expression markup is "-"
    assert_template_result(
      "",
      "{{ - 'theme.css' - }}",
    )
  end

  def test_expression_cache
    skip("Liquid-C does not support Expression caching") if defined?(Liquid::C) && Liquid::C.enabled

    cache = {}
    template = <<~LIQUID
      {% assign x = 1 %}
      {{ x }}
      {% assign x = 2 %}
      {{ x }}
      {% assign y = 1 %}
      {{ y }}
    LIQUID

    Liquid::Template.parse(template, expression_cache: cache).render

    assert_equal(
      ["1", "2", "x", "y"],
      cache.to_a.map { _1[0] }.sort,
    )
  end

  def test_expression_cache_with_true_boolean
    skip("Liquid-C does not support Expression caching") if defined?(Liquid::C) && Liquid::C.enabled

    template = <<~LIQUID
      {% assign x = 1 %}
      {{ x }}
      {% assign x = 2 %}
      {{ x }}
      {% assign y = 1 %}
      {{ y }}
    LIQUID

    parse_context = ParseContext.new(expression_cache: true)

    Liquid::Template.parse(template, parse_context).render

    cache = parse_context.instance_variable_get(:@expression_cache)

    assert_equal(
      ["1", "2", "x", "y"],
      cache.to_a.map { _1[0] }.sort,
    )
  end

  def test_expression_cache_with_lru_redux
    skip("Liquid-C does not support Expression caching") if defined?(Liquid::C) && Liquid::C.enabled

    cache = LruRedux::Cache.new(10)
    template = <<~LIQUID
      {% assign x = 1 %}
      {{ x }}
      {% assign x = 2 %}
      {{ x }}
      {% assign y = 1 %}
      {{ y }}
    LIQUID

    Liquid::Template.parse(template, expression_cache: cache).render

    assert_equal(
      ["1", "2", "x", "y"],
      cache.to_a.map { _1[0] }.sort,
    )
  end

  def test_disable_expression_cache
    skip("Liquid-C does not support Expression caching") if defined?(Liquid::C) && Liquid::C.enabled

    template = <<~LIQUID
      {% assign x = 1 %}
      {{ x }}
      {% assign x = 2 %}
      {{ x }}
      {% assign y = 1 %}
      {{ y }}
    LIQUID

    parse_context = Liquid::ParseContext.new(expression_cache: false)
    Liquid::Template.parse(template, parse_context).render
    assert(parse_context.instance_variable_get(:@expression_cache).nil?)
  end

  private

  def assert_expression_result(expect, markup, **assigns)
    liquid = "{% if expect == #{markup} %}pass{% else %}got {{ #{markup} }}{% endif %}"
    assert_template_result("pass", liquid, { "expect" => expect, **assigns })
  end
end
