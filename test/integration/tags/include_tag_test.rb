# frozen_string_literal: true

require 'test_helper'

class TestFileSystem
  PARTIALS = {
    "nested_template" => "{% include 'header' %} {% include 'body' %} {% include 'footer' %}",
    "body" => "body {% include 'body_detail' %}",
  }

  def read_template_file(template_path)
    PARTIALS[template_path] || template_path
  end
end

class OtherFileSystem
  def read_template_file(_template_path)
    'from OtherFileSystem'
  end
end

class CountingFileSystem
  attr_reader :count
  def read_template_file(_template_path)
    @count ||= 0
    @count  += 1
    'from CountingFileSystem'
  end
end

class CustomInclude < Liquid::Tag
  Syntax = /(#{Liquid::QuotedFragment}+)(\s+(?:with|for)\s+(#{Liquid::QuotedFragment}+))?/o

  def initialize(tag_name, markup, tokens)
    markup =~ Syntax
    @template_name = Regexp.last_match(1)
    super
  end

  def parse(tokens)
  end

  def render_to_output_buffer(_context, output)
    output << @template_name[1..-2]
    output
  end
end

class IncludeTagTest < Minitest::Test
  include Liquid

  def setup
    @default_file_system = Liquid::Template.file_system
  end

  def teardown
    Liquid::Template.file_system = @default_file_system
  end

  def test_include_tag_looks_for_file_system_in_registers_first
    assert_equal('from OtherFileSystem',
      Template.parse("{% include 'pick_a_source' %}").render!({}, registers: { file_system: OtherFileSystem.new }))
  end

  def test_include_tag_with
    assert_template_result("Product: Draft 151cm ",
      "{% include 'product' with products[0] %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: { "product" => "Product: {{ product.title }} " })
  end

  def test_include_tag_with_alias
    assert_template_result("Product: Draft 151cm ",
      "{% include 'product_alias' with products[0] as product %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: { "product_alias" => "Product: {{ product.title }} " })
  end

  def test_include_tag_for_alias
    assert_template_result("Product: Draft 151cm Product: Element 155cm ",
      "{% include 'product_alias' for products as product %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: { "product_alias" => "Product: {{ product.title }} " })
  end

  def test_include_tag_with_default_name
    assert_template_result("Product: Draft 151cm ",
      "{% include 'product' %}", { "product" => { 'title' => 'Draft 151cm' } },
      partials: { "product" => "Product: {{ product.title }} " })
  end

  def test_include_tag_for
    assert_template_result("Product: Draft 151cm Product: Element 155cm ",
      "{% include 'product' for products %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: { "product" => "Product: {{ product.title }} " })
  end

  def test_include_tag_with_local_variables
    assert_template_result("Locale: test123 ", "{% include 'locale_variables' echo1: 'test123' %}",
      partials: { "locale_variables" => "Locale: {{echo1}} {{echo2}}" })
  end

  def test_include_tag_with_multiple_local_variables
    assert_template_result("Locale: test123 test321",
      "{% include 'locale_variables' echo1: 'test123', echo2: 'test321' %}",
      partials: { "locale_variables" => "Locale: {{echo1}} {{echo2}}" })
  end

  def test_include_tag_with_multiple_local_variables_from_context
    assert_template_result("Locale: test123 test321",
      "{% include 'locale_variables' echo1: echo1, echo2: more_echos.echo2 %}",
      { 'echo1' => 'test123', 'more_echos' => { "echo2" => 'test321' } },
      partials: { "locale_variables" => "Locale: {{echo1}} {{echo2}}" })
  end

  def test_included_templates_assigns_variables
    assert_template_result("bar", "{% include 'assignments' %}{{ foo }}",
      partials: { 'assignments' => "{% assign foo = 'bar' %}" })
  end

  def test_nested_include_tag
    partials = { "body" => "body {% include 'body_detail' %}", "body_detail" => "body_detail" }
    assert_template_result("body body_detail", "{% include 'body' %}", partials: partials)

    partials = partials.merge({
      "nested_template" => "{% include 'header' %} {% include 'body' %} {% include 'footer' %}",
      "header" => "header",
      "footer" => "footer",
    })
    assert_template_result("header body body_detail footer", "{% include 'nested_template' %}", partials: partials)
  end

  def test_nested_include_with_variable
    partials = {
      "nested_product_template" => "Product: {{ nested_product_template.title }} {%include 'details'%} ",
      "details" => "details",
    }

    assert_template_result("Product: Draft 151cm details ",
      "{% include 'nested_product_template' with product %}", { "product" => { "title" => 'Draft 151cm' } },
      partials: partials)

    assert_template_result("Product: Draft 151cm details Product: Element 155cm details ",
      "{% include 'nested_product_template' for products %}", { "products" => [{ "title" => 'Draft 151cm' }, { "title" => 'Element 155cm' }] },
      partials: partials)
  end

  def test_recursively_included_template_does_not_produce_endless_loop
    infinite_file_system = Class.new do
      def read_template_file(_template_path)
        "-{% include 'loop' %}"
      end
    end

    Liquid::Template.file_system = infinite_file_system.new

    assert_raises(Liquid::StackLevelError) do
      Template.parse("{% include 'loop' %}").render!
    end
  end

  def test_dynamically_choosen_template
    assert_template_result("Test123", "{% include template %}", { "template" => 'Test123' },
      partials: { "Test123" => "Test123" })

    assert_template_result("Test321", "{% include template %}", { "template" => 'Test321' },
      partials: { "Test321" => "Test321" })

    assert_template_result("Product: Draft 151cm ", "{% include template for product %}",
      { "template" => 'product', 'product' => { 'title' => 'Draft 151cm' } },
      partials: { "product" => "Product: {{ product.title }} " })
  end

  def test_include_tag_caches_second_read_of_same_partial
    file_system = CountingFileSystem.new
    assert_equal('from CountingFileSystemfrom CountingFileSystem',
      Template.parse("{% include 'pick_a_source' %}{% include 'pick_a_source' %}").render!({}, registers: { file_system: file_system }))
    assert_equal(1, file_system.count)
  end

  def test_include_tag_doesnt_cache_partials_across_renders
    file_system = CountingFileSystem.new
    assert_equal('from CountingFileSystem',
      Template.parse("{% include 'pick_a_source' %}").render!({}, registers: { file_system: file_system }))
    assert_equal(1, file_system.count)

    assert_equal('from CountingFileSystem',
      Template.parse("{% include 'pick_a_source' %}").render!({}, registers: { file_system: file_system }))
    assert_equal(2, file_system.count)
  end

  def test_include_tag_within_if_statement
    assert_template_result("foo_if_true", "{% if true %}{% include 'foo_if_true' %}{% endif %}",
      partials: { "foo_if_true" => "foo_if_true" })
  end

  def test_custom_include_tag
    original_tag = Liquid::Template.tags['include']
    Liquid::Template.tags['include'] = CustomInclude
    begin
      assert_equal("custom_foo",
        Template.parse("{% include 'custom_foo' %}").render!)
    ensure
      Liquid::Template.tags['include'] = original_tag
    end
  end

  def test_custom_include_tag_within_if_statement
    original_tag = Liquid::Template.tags['include']
    Liquid::Template.tags['include'] = CustomInclude
    begin
      assert_equal("custom_foo_if_true",
        Template.parse("{% if true %}{% include 'custom_foo_if_true' %}{% endif %}").render!)
    ensure
      Liquid::Template.tags['include'] = original_tag
    end
  end

  def test_does_not_add_error_in_strict_mode_for_missing_variable
    Liquid::Template.file_system = TestFileSystem.new

    a = Liquid::Template.parse(' {% include "nested_template" %}')
    a.render!
    assert_empty(a.errors)
  end

  def test_passing_options_to_included_templates
    Liquid::Template.file_system = TestFileSystem.new
    assert_raises(Liquid::SyntaxError) do
      Template.parse("{% include template %}", error_mode: :strict).render!("template" => '{{ "X" || downcase }}')
    end
    with_error_mode(:lax) do
      assert_equal('x', Template.parse("{% include template %}", error_mode: :strict, include_options_blacklist: true).render!("template" => '{{ "X" || downcase }}'))
    end
    assert_raises(Liquid::SyntaxError) do
      Template.parse("{% include template %}", error_mode: :strict, include_options_blacklist: [:locale]).render!("template" => '{{ "X" || downcase }}')
    end
    with_error_mode(:lax) do
      assert_equal('x', Template.parse("{% include template %}", error_mode: :strict, include_options_blacklist: [:error_mode]).render!("template" => '{{ "X" || downcase }}'))
    end
  end

  def test_render_raise_argument_error_when_template_is_undefined
    assert_template_result("Liquid error (line 1): Argument error in tag 'include' - Illegal template name",
      "{% include undefined_variable %}", render_errors: true)

    assert_template_result("Liquid error (line 1): Argument error in tag 'include' - Illegal template name",
      "{% include nil %}", render_errors: true)
  end

  def test_render_raise_argument_error_when_template_is_not_a_string
    assert_template_result("Liquid error (line 1): Argument error in tag 'include' - Illegal template name",
      "{% include 123 %}", render_errors: true)
  end

  def test_including_via_variable_value
    assert_template_result("from TestFileSystem", "{% assign page = 'pick_a_source' %}{% include page %}",
      partials: { "pick_a_source" => "from TestFileSystem" })

    partials = { "product" => "Product: {{ product.title }} " }

    assert_template_result("Product: Draft 151cm ", "{% assign page = 'product' %}{% include page %}",
      { "product" => { 'title' => 'Draft 151cm' } },
      partials: partials)

    assert_template_result("Product: Draft 151cm ", "{% assign page = 'product' %}{% include page for foo %}",
      { "foo" => { 'title' => 'Draft 151cm' } },
      partials: partials)
  end

  def test_including_with_strict_variables
    Liquid::Template.file_system = StubFileSystem.new({ "simple" => "simple" })
    template = Liquid::Template.parse("{% include 'simple' %}", error_mode: :warn)
    template.render(nil, strict_variables: true)

    assert_equal([], template.errors)
  end

  def test_break_through_include
    assert_template_result("1", "{% for i in (1..3) %}{{ i }}{% break %}{{ i }}{% endfor %}")
    assert_template_result("1", "{% for i in (1..3) %}{{ i }}{% include 'break' %}{{ i }}{% endfor %}",
      partials: { 'break' => "{% break %}" })
  end
end # IncludeTagTest
