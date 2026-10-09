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

  def test_doc_tag_body_content
    doc_content = "  Documentation content\n  @param {string} foo - test\n"
    template_source = "{% doc %}#{doc_content}{% enddoc %}"

    doc_tag = nil
    ParseTreeVisitor
      .for(Template.parse(template_source).root)
      .add_callback_for(Liquid::Doc) do |tag|
        doc_tag = tag
      end
      .visit

    assert_equal(doc_content, doc_tag.nodelist.first.to_s)
  end

  def test_doc_tag_does_not_support_extra_arguments
    error = assert_raises(Liquid::SyntaxError) do
      template = <<~LIQUID.chomp
        {% doc extra %}
        {% enddoc %}
      LIQUID

      Liquid::Template.parse(template)
    end

    exp_error = "Liquid syntax error: Syntax Error in 'doc' - Valid syntax: {% doc %}{% enddoc %}"
    act_error = error.message

    assert_equal(exp_error, act_error)
  end

  def test_doc_tag_must_support_valid_tags
    assert_match_syntax_error("Liquid syntax error (line 1): 'doc' tag was never closed", '{% doc %} foo')
    assert_match_syntax_error("Liquid syntax error (line 1): Syntax Error in 'doc' - Valid syntax: {% doc %}{% enddoc %}", '{% doc } foo {% enddoc %}')
    assert_match_syntax_error("Liquid syntax error (line 1): Syntax Error in 'doc' - Valid syntax: {% doc %}{% enddoc %}", '{% doc } foo %}{% enddoc %}')
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

  def test_doc_tag_ignores_unclosed_assign
    template = <<~LIQUID.chomp
      {% doc %}
        {% assign foo = "1"
      {% enddoc %}
    LIQUID

    assert_template_result('', template)
  end

  def test_doc_tag_ignores_malformed_syntax
    template = <<~LIQUID.chomp
      {% doc %}
      {% {{ {%- enddoc %}
    LIQUID

    assert_template_result('', template)
  end

  def test_doc_tag_captures_token_before_enddoc
    template_source = "{% doc %}{{ incomplete{% enddoc %}"

    doc_tag = nil
    ParseTreeVisitor
      .for(Template.parse(template_source).root)
      .add_callback_for(Liquid::Doc) do |tag|
        doc_tag = tag
      end
      .visit

    assert_equal("{{ incomplete", doc_tag.nodelist.first.to_s)
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
    assert_template_result("Hello!", <<~LIQUID.chomp)
      {%- doc %}Whitespace control!{% enddoc -%}
      Hello!
    LIQUID
  end

  def test_doc_tag_delimiter_handling
    assert_template_result('', <<~LIQUID.chomp)
      {%- if true -%}
        {%- doc -%}
          {%- docEXTRA -%}wut{% enddocEXTRA -%}xyz
        {%- enddoc -%}
      {%- endif -%}
    LIQUID

    assert_template_result('', "{% doc %}123{% enddoc xyz %}")
    assert_template_result('', "{% doc %}123{% enddoc\txyz %}")
    assert_template_result('', "{% doc %}123{% enddoc\nxyz %}")
    assert_template_result('', "{% doc %}123{% enddoc\n   xyz  enddoc %}")
  end

  def test_doc_tag_visitor
    template_source = '{% doc %}{% enddoc %}'

    assert_equal(
      [Liquid::Doc],
      visit(template_source),
    )
  end

  def test_doc_tag_blank_with_empty_content
    template_source = "{% doc %}{% enddoc %}"

    doc_tag = nil
    ParseTreeVisitor
      .for(Template.parse(template_source).root)
      .add_callback_for(Liquid::Doc) do |tag|
        doc_tag = tag
      end
      .visit

    assert_equal(true, doc_tag.blank?)
  end

  def test_doc_tag_blank_with_content
    template_source = "{% doc %}Some documentation{% enddoc %}"

    doc_tag = nil
    ParseTreeVisitor
      .for(Template.parse(template_source).root)
      .add_callback_for(Liquid::Doc) do |tag|
        doc_tag = tag
      end
      .visit

    assert_equal(false, doc_tag.blank?)
  end

  def test_doc_tag_blank_with_whitespace_only
    template_source = "{% doc %}    {% enddoc %}"

    doc_tag = nil
    ParseTreeVisitor
      .for(Template.parse(template_source).root)
      .add_callback_for(Liquid::Doc) do |tag|
        doc_tag = tag
      end
      .visit

    assert_equal(false, doc_tag.blank?)
  end

  def test_doc_tag_nodelist_returns_array_with_body
    doc_content = "Documentation content\n@param {string} foo"
    template_source = "{% doc %}#{doc_content}{% enddoc %}"

    doc_tag = nil
    ParseTreeVisitor
      .for(Template.parse(template_source).root)
      .add_callback_for(Liquid::Doc) do |tag|
        doc_tag = tag
      end
      .visit

    assert_equal([doc_content], doc_tag.nodelist)
    assert_equal(1, doc_tag.nodelist.length)
    assert_equal(doc_content, doc_tag.nodelist.first)
  end

  def test_doc_tag_nodelist_with_empty_content
    template_source = "{% doc %}{% enddoc %}"

    doc_tag = nil
    ParseTreeVisitor
      .for(Template.parse(template_source).root)
      .add_callback_for(Liquid::Doc) do |tag|
        doc_tag = tag
      end
      .visit

    assert_equal([""], doc_tag.nodelist)
    assert_equal(1, doc_tag.nodelist.length)
  end

  private

  def traversal(template)
    ParseTreeVisitor
      .for(Template.parse(template).root)
      .add_callback_for(Liquid::Doc) do |tag|
        tag_class = tag.class
        tag_class
      end
  end

  def visit(template)
    traversal(template).visit.flatten.compact
  end
end
