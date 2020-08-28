# frozen_string_literal: true

require 'test_helper'

class LiquidTagTest < Minitest::Test
  include Liquid

  def test_liquid_tag
    assert_template_result('1 2 3', <<~LIQUID, 'array' => [1, 2, 3])
      {%- liquid
        echo array | join: " "
      -%}
    LIQUID

    assert_template_result('1 2 3', <<~LIQUID, 'array' => [1, 2, 3])
      {%- liquid
        for value in array
          echo value
          unless forloop.last
            echo " "
          endunless
        endfor
      -%}
    LIQUID

    assert_template_result('4 8 12 6', <<~LIQUID, 'array' => [1, 2, 3])
      {%- liquid
        for value in array
          assign double_value = value | times: 2
          echo double_value | times: 2
          unless forloop.last
            echo " "
          endunless
        endfor

        echo " "
        echo double_value
      -%}
    LIQUID

    assert_template_result('abc', <<~LIQUID)
      {%- liquid echo "a" -%}
      b
      {%- liquid echo "c" -%}
    LIQUID
  end

  def test_liquid_tag_errors
    assert_match_syntax_error("syntax error (line 1): Unknown tag 'error'", <<~LIQUID)
      {%- liquid error no such tag -%}
    LIQUID

    assert_match_syntax_error("syntax error (line 7): Unknown tag 'error'", <<~LIQUID)
      {{ test }}

      {%-
      liquid
        for value in array

          error no such tag
        endfor
      -%}
    LIQUID

    assert_match_syntax_error("syntax error (line 2): Unknown tag '!!! the guards are vigilant'", <<~LIQUID)
      {%- liquid
        !!! the guards are vigilant
      -%}
    LIQUID

    assert_match_syntax_error("syntax error (line 4): 'for' tag was never closed", <<~LIQUID)
      {%- liquid
        for value in array
          echo 'forgot to close the for tag'
      -%}
    LIQUID
  end

  def test_line_number_is_correct_after_a_blank_token
    assert_match_syntax_error("syntax error (line 3): Unknown tag 'error'", "{% liquid echo ''\n\n error %}")
    assert_match_syntax_error("syntax error (line 3): Unknown tag 'error'", "{% liquid echo ''\n  \n error %}")
  end

  def test_nested_liquid_tag
    assert_template_result('good', <<~LIQUID)
      {%- if true %}
        {%- liquid
          echo "good"
        %}
      {%- endif -%}
    LIQUID
  end

  def test_cannot_open_blocks_living_past_a_liquid_tag
    assert_match_syntax_error("syntax error (line 3): 'if' tag was never closed", <<~LIQUID)
      {%- liquid
        if true
      -%}
      {%- endif -%}
    LIQUID
  end

  def test_cannot_close_blocks_created_before_a_liquid_tag
    assert_match_syntax_error("syntax error (line 3): 'endif' is not a valid delimiter for liquid tags. use %}", <<~LIQUID)
      {%- if true -%}
      42
      {%- liquid endif -%}
    LIQUID
  end

  def test_liquid_tag_in_raw
    assert_template_result("{% liquid echo 'test' %}\n", <<~LIQUID)
      {% raw %}{% liquid echo 'test' %}{% endraw %}
    LIQUID
  end
end
