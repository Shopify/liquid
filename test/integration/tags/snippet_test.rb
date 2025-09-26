# frozen_string_literal: true

require 'test_helper'

class SnippetTest < Minitest::Test
  include Liquid

  def test_valid_inline_snippet
    template = <<~LIQUID.strip
      {% snippet input %}
        Hey
      {% endsnippet %}
    LIQUID
    expected = ''

    assert_template_result(expected, template)
  end

  def test_render_inline_snippet
    template = <<~LIQUID.strip
      {% snippet hey %}
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
      {% snippet input %}
      <input />
      {% endsnippet %}

      {% snippet banner %}
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
      {% snippet input %}
      <input type="{{ type }}" />
      {% endsnippet %}

      {%- render "input", type: "text" -%}
    LIQUID
    expected = <<~OUTPUT

      <input type="text" />
    OUTPUT

    assert_template_result(expected, template)
  end

  def test_render_inline_snippet_with_doc_tag
    template = <<~LIQUID.strip
      {% snippet input %}
      {% doc  %}
        @param {string} type - Input type.
      {% enddoc %}

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
      {% snippet input %}
      {% doc %}
        @param {string} type - Input type.
        @param {string} value - Input value.
      {% enddoc %}

      <input type="{{ type }}" value="{{ value }}" />
      {% endsnippet %}

      {%- render "input", type: "text", value: "Hello" -%}
    LIQUID
    expected = <<~OUTPUT



      <input type="text" value="Hello" />
    OUTPUT

    assert_template_result(expected, template)
  end

  def test_render_inline_snippets_using_same_argument_name
    template = <<~LIQUID.strip
      {% snippet input %}
      <input type="{{ type }}" />
      {% endsnippet %}

      {% snippet inputs %}
      <input type="{{ type }}" value="{{ value }}" />
      {% endsnippet %}

      {%- render "input", type: "text" -%}
      {%- render "inputs", type: "password", value: "pass" -%}
    LIQUID

    expected = <<~OUTPUT



      <input type="text" />

      <input type="password" value="pass" />
    OUTPUT

    assert_template_result(expected, template)
  end

  def test_render_inline_snippet_empty_string_when_missing_argument
    template = <<~LIQUID.strip
      {% snippet input %}
      {% doc %}
        @param {string} type - Input type.
        @param {string} value - Input value.
      {% enddoc %}

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
      {% snippet input %}
      {% doc %}
        @param {string} type - Input type.
        @param {string} value - Input value.
      {% enddoc %}

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
      {% snippet input %}
      {% doc %}
        @param {string} type - Input type.
      {% enddoc %}

      <input type="{{ type }}" />
      {% endsnippet %}

      {% snippet no_leak %}
      <input type="{{ type }}" />
      {% endsnippet %}

      {%- render "input", type: "text" -%}
      {%- render "no_leak" -%}
    LIQUID
    expected = <<~OUTPUT





      <input type="text" />

      <input type="" />
    OUTPUT

    assert_template_result(expected, template)
  end

  def test_render_parent_context_variable
    template = <<~LIQUID.strip
      {% assign color_scheme = 'dark' %}

      {% snippet header %}
      {% doc %}
        @param {string} message - Message.
      {% enddoc %}

      <div class="header header--{{ color_scheme }}">
        {{ message }}
      </div>
      {% endsnippet %}

      {%- render "header", message: "Welcome to my site" -%}
    LIQUID
    expected = <<~OUTPUT





      <div class="header header--dark">
        Welcome to my site
      </div>
    OUTPUT

    assert_template_result(expected, template)
  end

  def test_deeply_nested_snippets
    template = <<~LIQUID.strip
      {% assign color_scheme = 'first-color' %}
      {% snippet first %}
      {% assign color_scheme = 'second-color' %}
      {% snippet second %}
      {% assign color_scheme = 'third-color' %}
      {% snippet third %}
      <div class="header header--{{ color_scheme }}">
        This is a header
      </div>
      {% endsnippet %}
      {%- render "third" -%}
      {% endsnippet %}
      {%- render "second" -%}
      {% endsnippet %}

      {%- render "first" -%}
    LIQUID
    expected = <<~OUTPUT






      <div class="header header--third-color">
        This is a header
      </div>
    OUTPUT

    assert_template_result(expected, template)
  end

  def test_render_snippet_with_variables_in_both_scopes
    template = <<~LIQUID.strip
      {% assign color_scheme = 'dark' %}

      {% snippet header %}
      {% assign color_scheme = 'light' %}
      <div class="header header--{{ color_scheme }}">
        {{ message }}
      </div>
      {% endsnippet %}

      {{ color_scheme }}

      {%- render "header", message: 'Welcome to my site' -%}
    LIQUID
    expected = <<~OUTPUT




      dark

      <div class="header header--light">
        Welcome to my site
      </div>
    OUTPUT

    assert_template_result(expected, template)
  end

  # def test_render_snippets_as_arguments
  #   template = <<~LIQUID.strip
  #     {% assign color_scheme = 'dark' %}

  #     {% snippet main_header %}
  #       {% assign color_scheme = 'auto' %}

  #       <div class="main main--{{ color_scheme }}">
  #         {%- render "header", message: 'Welcome to my site' -%}
  #       </div>
  #     {% endsnippet %}

  #     {% snippet header %}
  #       <div class="header header--{{ color_scheme }}">
  #         {{ message }}
  #       </div>
  #     {% endsnippet %}

  #     {%- render "main_header", header: header -%}
  #   LIQUID
  #   expected = <<~OUTPUT
  #       <div class="main main--auto">
  #       <div class="header header--auto">
  #         Welcome to my site
  #       </div>
  #     </div>
  #   OUTPUT

  #   assert_template_result(expected, template)
  # end
end
