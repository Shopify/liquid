# frozen_string_literal: true

require 'test_helper'

class CommentTagUnitTest < Minitest::Test
  def test_comment_inside_liquid_tag
    assert_template_result("", <<~LIQUID.chomp)
      {% liquid
        if 1 != 1
        comment
        else
          echo 123
        endcomment
        endif
      %}
    LIQUID
  end

  def test_does_not_parse_nodes_inside_a_comment
    assert_template_result("", <<~LIQUID.chomp)
      {% comment %}
        {% if true %}
        {% if ... %}
        {%- for ? -%}
        {% while true %}
        {%
          unless if
        %}
        {% endcase %}
      {% endcomment %}
    LIQUID
  end

  def test_allows_incomplete_tags_inside_a_comment
    assert_template_result("", <<~LIQUID.chomp)
      {% comment %}
        {% assign foo = "1"
      {% endcomment %}
    LIQUID

    assert_template_result("", <<~LIQUID.chomp)
      {% comment %}
        {% comment %}
          {% invalid
        {% endcomment %}
      {% endcomment %}
    LIQUID

    assert_template_result("", <<~LIQUID.chomp)
      {% comment %}
      {% {{ {%- endcomment %}
    LIQUID
  end

  def test_child_comment_tags_need_to_be_closed
    assert_template_result("", <<~LIQUID.chomp)
      {% comment %}
        {% comment %}
          {% comment %}{%    endcomment     %}
        {% endcomment %}
      {% endcomment %}
    LIQUID

    assert_raises(Liquid::SyntaxError) do
      assert_template_result("", <<~LIQUID.chomp)
        {% comment %}
          {% comment %}
            {% comment %}
          {% endcomment %}
        {% endcomment %}
      LIQUID
    end
  end

  def test_child_raw_tags_need_to_be_closed
    assert_template_result("", <<~LIQUID.chomp)
      {% comment %}
        {% raw %}
          {% endcomment %}
        {% endraw %}
      {% endcomment %}
    LIQUID

    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse(<<~LIQUID.chomp)
        {% comment %}
          {% raw %}
          {% endcomment %}
        {% endcomment %}
      LIQUID
    end
  end

  def test_error_line_number_is_correct
    template = Liquid::Template.parse(<<~LIQUID.chomp, line_numbers: true)
      {% comment %}
        {% if true %}
      {% endcomment %}
      {{ errors.standard_error }}
    LIQUID

    output = template.render('errors' => ErrorDrop.new)
    expected = <<~TEXT.chomp

      Liquid error (line 4): standard error
    TEXT

    assert_equal(expected, output)
  end

  def test_comment_tag_delimiter_with_extra_strings
    assert_template_result(
      '',
      <<~LIQUID.chomp,
        {% comment %}
          {% comment %}
          {% endcomment
          {% if true %}
          {% endif %}
        {% endcomment %}
      LIQUID
    )
  end
end
