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
      {% snippet "input" %}
      Hey
      {% endsnippet %}

      {%- render "input" -%}
    LIQUID
    expected = <<~OUTPUT

      Hey
    OUTPUT

    assert_template_result(expected, template)
  end
end
