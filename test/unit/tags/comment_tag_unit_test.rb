# frozen_string_literal: true

require 'test_helper'

class CommentTagUnitTest < Minitest::Test
  def test_does_not_parse_nodes_inside_a_comment
    template = Template.parse(<<~LIQUID.chomp, line_numbers: true)
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

    assert_equal("", template.render)
  end

  def test_child_comment_tags_need_to_be_closed
    template = Template.parse(<<~LIQUID.chomp, line_numbers: true)
      {% comment %}
        {% comment %}
          {% comment %}{%    endcomment     %}
        {% endcomment %}
      {% endcomment %}
    LIQUID

    assert_equal("", template.render)

    assert_raises(SyntaxError) do
      Template.parse(<<~LIQUID.chomp, line_numbers: true)
        {% comment %}
          {% comment %}
            {% comment %}
          {% endcomment %}
        {% endcomment %}
      LIQUID
    end
  end

  def test_child_raw_tags_need_to_be_closed
    template = Template.parse(<<~LIQUID.chomp, line_numbers: true)
      {% comment %}
        {% raw %}
          {% endcomment %}
        {% endraw %}
      {% endcomment %}
    LIQUID

    assert_equal("", template.render)

    assert_raises(SyntaxError) do
      Template.parse(<<~LIQUID.chomp, line_numbers: true)
        {% comment %}
          {% raw %}
          {% endcomment %}
        {% endcomment %}
      LIQUID
    end
  end

  def test_error_line_number_is_correct
    template = Template.parse(<<~LIQUID.chomp, line_numbers: true)
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
end