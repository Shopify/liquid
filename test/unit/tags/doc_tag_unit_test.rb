# frozen_string_literal: true

require 'test_helper'

class DocTagUnitTest < Minitest::Test
  def test_doc_inside_liquid_tag
    assert_template_result('', <<~LIQUID.chomp)
      {% liquid
        if 1 != 1
          doc
            else
            echo 123
          enddoc
        endif
      %}
    LIQUID
  end

  def test_does_not_parse_nodes_inside_a_doc
    assert_template_result('', <<~LIQUID.chomp)
      {% doc %}
        {% if true %}
        {% if ... %}
        {%- for ? -%}
        {% while true %}
        {%
          unless if
        %}
        {% endcase %}
      {% enddoc %}
    LIQUID
  end

  def test_allows_unclosed_tags
    assert_template_result('', <<~LIQUID.chomp)
      {% doc %}
        {% if true %}
      {% enddoc %}
    LIQUID
  end

  def test_open_tags_in_doc
    assert_template_result('', <<~LIQUID.chomp)
      {% doc %}
        {% assign a = 123 {% doc %}
      {% enddoc %}
    LIQUID

    assert_raises(Liquid::SyntaxError) do
      assert_template_result('', <<~LIQUID.chomp)
        {% doc %}
          {% assign foo = "1"
        {% enddoc %}
      LIQUID
    end

    assert_raises(Liquid::SyntaxError) do
      assert_template_result('', <<~LIQUID.chomp)
        {% doc %}
          {% doc %}
            {% invalid
          {% enddoc %}
        {% enddoc %}
      LIQUID
    end

    assert_raises(Liquid::SyntaxError) do
      assert_template_result('', <<~LIQUID.chomp)
        {% doc %}
        {% {{ {%- enddoc %}
      LIQUID
    end
  end

  def test_child_doc_tags_need_to_be_closed
    assert_template_result('', <<~LIQUID.chomp)
      {% doc %}
        {% doc %}
          {% doc %}{% enddoc %}
        {% enddoc %}
      {% enddoc %}
    LIQUID

    assert_raises(Liquid::SyntaxError) do
      assert_template_result('', <<~LIQUID.chomp)
        {% doc %}
          {% doc %}
            {% doc %}
          {% enddoc %}
        {% enddoc %}
      LIQUID
    end
  end

  def test_child_raw_tags_need_to_be_closed
    assert_template_result('', <<~LIQUID.chomp)
      {% doc %}
        {% raw %}
          {% enddoc %}
        {% endraw %}
      {% enddoc %}
    LIQUID

    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse(<<~LIQUID.chomp)
        {% doc %}
          {% raw %}
          {% enddoc %}
        {% enddoc %}
      LIQUID
    end
  end

  def test_error_line_number_is_correct
    template = Liquid::Template.parse(<<~LIQUID.chomp, line_numbers: true)
      {% doc %}
        {% if true %}
      {% enddoc %}
      {{ errors.standard_error }}
    LIQUID

    output = template.render('errors' => ErrorDrop.new)
    expected = <<~TEXT.chomp

      Liquid error (line 4): standard error
    TEXT

    assert_equal(expected, output)
  end

  def test_doc_tag_delimiter_with_extra_strings
    assert_template_result(
      '',
      <<~LIQUID.chomp,
        {% doc %}
          {% doc %}
          {% enddoc
          {% if true %}
          {% endif %}
        {% enddoc %}
      LIQUID
    )
  end

  def test_nested_doc_tag_with_extra_strings
    assert_template_result(
      '',
      <<~LIQUID.chomp,
        {% doc %}
          {% doc
            {% assign foo = 1 %}
          {% enddoc
          {% assign foo = 1 %}
        {% enddoc %}
      LIQUID
    )
  end

  def test_ignores_delimiter_with_extra_strings
    assert_template_result('', <<~LIQUID.chomp)
      {% if true %}
        {% doc %}
          {% docEXTRA %}wut{% enddocEXTRA %}xyz
        {% enddoc %}
      {% endif %}
    LIQUID
  end

  def test_delimiter_can_have_extra_strings
    assert_template_result('', "{% doc %}123{% enddoc xyz %}")
    assert_template_result('', "{% doc %}123{% enddoc\txyz %}")
    assert_template_result('', "{% doc %}123{% enddoc\nxyz %}")
    assert_template_result('', "{% doc %}123{% enddoc\n   xyz  enddoc %}")
    assert_template_result('', "{%doc}{% assign a = 1 %}{%enddoc}{% endif %}")
  end

  def test_with_whitespace_control
    assert_template_result("Hello!", "      {%- doc -%}123{%- enddoc -%}Hello!")
    assert_template_result("Hello!", "{%- doc -%}123{%- enddoc -%}     Hello!")
    assert_template_result("Hello!", "      {%- doc -%}123{%- enddoc -%}     Hello!")

    assert_template_result("Hello!", <<~LIQUID.chomp)
      {%- doc %}Whitespace control!{% enddoc -%}
      Hello!
    LIQUID
  end

  def test_dont_override_liquid_tag_whitespace_control
    assert_template_result("Hello!World!", <<~LIQUID.chomp)
      Hello!
      {%- liquid
        doc
         this is inside a liquid tag
        enddoc
      -%}
      World!
    LIQUID
  end
end
