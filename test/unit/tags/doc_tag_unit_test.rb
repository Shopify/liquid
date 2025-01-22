# frozen_string_literal: true

require 'test_helper'

class DocTagUnitTest < Minitest::Test
  def test_doc_tag
    template = <<~LIQUID.chomp
      {% doc %}
        Renders loading-spinner.

        @param {string} foo - some foo
        @param {string} [bar] - optional bar

        @example
        {% render 'loading-spinner', foo: 'foo' %}
        {% render 'loading-spinner', foo: 'foo', bar: 'bar' %}
      {% enddoc %}
    LIQUID

    assert_template_result('', template)
  end

  def test_doc_tag_inside_liquid_tag
    template = <<~LIQUID.chomp
      {% liquid
        doc
          Assigns foo to 1.
        enddoc
        assign foo = 1
      %}
    LIQUID

    assert_template_result('', template)
  end

  def test_doc_tag_inside_liquid_tag_with_control_flow_nodes
    template = <<~LIQUID.chomp
      {% liquid
        if 1 != 1
          doc
            else
            echo 123
          enddoc
        endif
      %}
    LIQUID

    assert_template_result('', template)
  end

  def test_doc_tag_ignores_liquid_nodes
    template = <<~LIQUID.chomp
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

    assert_template_result('', template)
  end

  def test_doc_tag_ignores_unclosed_liquid_tags
    template = <<~LIQUID.chomp
      {% doc %}
        {% if true %}
      {% enddoc %}
    LIQUID

    assert_template_result('', template)
  end

  def test_doc_tag_does_not_allow_nested_docs
    error = assert_raises(Liquid::SyntaxError) do
      template = <<~LIQUID.chomp
        {% doc %}
          {% doc %}
            {% doc %}
        {% enddoc %}
      LIQUID

      Liquid::Template.parse(template)
    end

    exp_error = "Liquid syntax error: Syntax Error in 'doc' - Nested doc tags are not allowed"
    act_error = error.message

    assert_equal(exp_error, act_error)
  end

  def test_doc_tag_ignores_nested_raw_tags
    template = <<~LIQUID.chomp
      {% doc %}
        {% raw %}
      {% enddoc %}
    LIQUID

    assert_template_result('', template)
  end

  def test_doc_tag_raises_an_error_for_unclosed_assign
    error = assert_raises(Liquid::SyntaxError) do
      template = <<~LIQUID.chomp
        {% doc %}
          {% assign foo = "1"
        {% enddoc %}
      LIQUID

      Liquid::Template.parse(template)
    end

    exp_error = "Liquid syntax error: 'doc' tag was never closed"
    act_error = error.message

    assert_equal(exp_error, act_error)
  end

  def test_doc_tag_raises_an_error_for_malformed_syntax
    error = assert_raises(Liquid::SyntaxError) do
      template = <<~LIQUID.chomp
        {% doc %}
        {% {{ {%- enddoc %}
      LIQUID

      Liquid::Template.parse(template)
    end

    exp_error = "Liquid syntax error: 'doc' tag was never closed"
    act_error = error.message

    assert_equal(exp_error, act_error)
  end

  def test_doc_tag_preserves_error_line_numbers
    template = Liquid::Template.parse(<<~LIQUID.chomp, line_numbers: true)
      {% doc %}
        {% if true %}
      {% enddoc %}
      {{ errors.standard_error }}
    LIQUID

    expected = <<~TEXT.chomp

      Liquid error (line 4): standard error
    TEXT

    assert_equal(expected, template.render('errors' => ErrorDrop.new))
  end

  def test_doc_tag_whitespace_control
    # Basic whitespace control
    assert_template_result("Hello!", "      {%- doc -%}123{%- enddoc -%}Hello!")
    assert_template_result("Hello!", "{%- doc -%}123{%- enddoc -%}     Hello!")
    assert_template_result("Hello!", "      {%- doc -%}123{%- enddoc -%}     Hello!")

    # Whitespace control within liquid tags
    assert_template_result("Hello!World!", <<~LIQUID.chomp)
      Hello!
      {%- liquid
        doc
         this is inside a liquid tag
        enddoc
      -%}
      World!
    LIQUID

    # Multiline whitespace control
    assert_template_result("Hello!", <<~LIQUID.chomp)
      {%- doc %}Whitespace control!{% enddoc -%}
      Hello!
    LIQUID
  end

  def test_doc_tag_delimiter_handling
    assert_template_result('', <<~LIQUID.chomp)
      {% if true %}
        {% doc %}
          {% docEXTRA %}wut{% enddocEXTRA %}xyz
        {% enddoc %}
      {% endif %}
    LIQUID

    assert_template_result('', "{% doc %}123{% enddoc xyz %}")
    assert_template_result('', "{% doc %}123{% enddoc\txyz %}")
    assert_template_result('', "{% doc %}123{% enddoc\nxyz %}")
    assert_template_result('', "{% doc %}123{% enddoc\n   xyz  enddoc %}")
    assert_template_result('', "{%doc}{% assign a = 1 %}{%enddoc}{% endif %}")
  end
end
