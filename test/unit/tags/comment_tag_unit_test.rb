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

  def test_allows_unclosed_tags
    assert_template_result('', <<~LIQUID.chomp)
      {% comment %}
        {% if true %}
      {% endcomment %}
    LIQUID
  end

  def test_open_tags_in_comment
    assert_template_result('', <<~LIQUID.chomp)
      {% comment %}
        {% assign a = 123 {% comment %}
      {% endcomment %}
    LIQUID

    assert_raises(Liquid::SyntaxError) do
      assert_template_result("", <<~LIQUID.chomp)
        {% comment %}
          {% assign foo = "1"
        {% endcomment %}
      LIQUID
    end

    assert_raises(Liquid::SyntaxError) do
      assert_template_result("", <<~LIQUID.chomp)
        {% comment %}
          {% comment %}
            {% invalid
          {% endcomment %}
        {% endcomment %}
      LIQUID
    end

    assert_raises(Liquid::SyntaxError) do
      assert_template_result("", <<~LIQUID.chomp)
        {% comment %}
        {% {{ {%- endcomment %}
      LIQUID
    end
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

  def test_nested_comment_tag_with_extra_strings
    assert_template_result(
      '',
      <<~LIQUID.chomp,
        {% comment %}
          {% comment
            {% assign foo = 1 %}
          {% endcomment
          {% assign foo = 1 %}
        {% endcomment %}
      LIQUID
    )
  end

  def test_ignores_delimiter_with_extra_strings
    assert_template_result(
      '',
      <<~LIQUID.chomp,
        {% if true %}
          {% comment %}
            {% commentXXXXX %}wut{% endcommentXXXXX %}
          {% endcomment %}
        {% endif %}
      LIQUID
    )
  end

  def test_delimiter_can_have_extra_strings
    assert_template_result('', "{% comment %}123{% endcomment xyz %}")
    assert_template_result('', "{% comment %}123{% endcomment\txyz %}")
    assert_template_result('', "{% comment %}123{% endcomment\nxyz %}")
    assert_template_result('', "{% comment %}123{% endcomment\n   xyz  endcomment %}")
    assert_template_result('', "{%comment}{% assign a = 1 %}{%endcomment}{% endif %}")
  end

  def test_with_whitespace_control
    assert_template_result("Hello!", "      {%- comment -%}123{%- endcomment -%}Hello!")
    assert_template_result("Hello!", "{%- comment -%}123{%- endcomment -%}     Hello!")
    assert_template_result("Hello!", "      {%- comment -%}123{%- endcomment -%}     Hello!")

    assert_template_result("Hello!", <<~LIQUID.chomp)
      {%- comment %}Whitespace control!{% endcomment -%}
      Hello!
    LIQUID
  end

  def test_dont_override_liquid_tag_whitespace_control
    assert_template_result("Hello!World!", <<~LIQUID.chomp)
      Hello!
      {%- liquid
        comment
         this is inside a liquid tag
        endcomment
      -%}
      World!
    LIQUID
  end
end
