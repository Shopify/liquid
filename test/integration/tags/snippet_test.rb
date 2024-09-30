# frozen_string_literal: true

require 'test_helper'

class SnippetTest < Minitest::Test
  include Liquid

  def test_valid_inline_snippet
    template = <<~LIQUID.strip
      {% snippet "input" %}
        Hey
      {% endsnippet %}
    LIQUID
    expected = ''

    assert_template_result(expected, template)
  end

  def test_invalid_inline_snippet
    template = <<~LIQUID.strip
      {% snippet input %}
        Hey
      {% endsnippet %}
    LIQUID
    expected = "Syntax Error in 'snippet' - Valid syntax: snippet [quoted string]"

    assert_match_syntax_error(expected, template)
  end

  def test_render_inline_snippet
    template = <<~LIQUID.strip
      {% snippet "hey" %}
      Hey
      {% endsnippet %}

      {%- render "hey" -%}
    LIQUID
    expected = <<~OUTPUT

      Hey
    OUTPUT

    assert_template_result(expected, template)
  end

  def test_render_multiple_inline_snippets
    template = <<~LIQUID.strip
      {% snippet "input" %}
      <input />
      {% endsnippet %}

      {% snippet "banner" %}
      <marquee direction="up" height="100px">
        Welcome to my store!
      </marquee>
      {% endsnippet %}

      {%- render "input" -%}
      {%- render "banner" -%}
    LIQUID
    expected = <<~OUTPUT



      <input />

      <marquee direction="up" height="100px">
        Welcome to my store!
      </marquee>
    OUTPUT

    assert_template_result(expected, template)
  end

  def test_render_inline_snippet_with_argument
    template = <<~LIQUID.strip
      {% snippet "input" |type| %}
      <input type="{{ type }}" />
      {% endsnippet %}

      {%- render "input", type: "text" -%}
    LIQUID
    expected = <<~OUTPUT

      <input type="text" />
    OUTPUT

    assert_template_result(expected, template)
  end

  def test_render_inline_snippet_with_multiple_arguments
    template = <<~LIQUID.strip
      {% snippet "input" |type, value| %}
      <input type="{{ type }}" value="{{ value }}" />
      {% endsnippet %}

      {%- render "input", type: "text", value: "Hello" -%}
    LIQUID
    expected = <<~OUTPUT

      <input type="text" value="Hello" />
    OUTPUT

    assert_template_result(expected, template)
  end

  def test_render_inline_snippet_empty_string_when_missing_argument
    template = <<~LIQUID.strip
      {% snippet "input" |type| %}
      <input type="{{ type }}" value="{{ value }}" />
      {% endsnippet %}

      {%- render "input", type: "text" -%}
    LIQUID
    expected = <<~OUTPUT

      <input type="text" value="" />
    OUTPUT

    assert_template_result(expected, template)
  end

  def test_render_inline_snippet_shouldnt_leak_context
    template = <<~LIQUID.strip
      {% snippet "input" |type, value| %}
      <input type="{{ type }}" value="{{ value }}" />
      {% endsnippet %}

      {%- render "input", type: "text", value: "Hello" -%}

      {{ type }}
      {{ value }}
    LIQUID
    expected = <<~OUTPUT

      <input type="text" value="Hello" />

    OUTPUT

    assert_template_result(expected, template)
  end

  def test_render_multiple_inline_snippets_without_leaking_context
    template = <<~LIQUID.strip
      {% snippet "input" |type| %}
      <input type="{{ type }}" />
      {% endsnippet %}

      {% snippet "banner"%}
        {{ type }}
      {% endsnippet %}

      {%- render "input", type: "text" -%}
      {%- render "banner" -%}
    LIQUID
    expected = <<~OUTPUT.strip

      <input type="text" />


    OUTPUT

    assert_template_result(expected, template)
  end
end
