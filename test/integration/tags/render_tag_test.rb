require 'test_helper'

class StubFileSystem
  def initialize(values)
    @values = values
  end

  def read_template_file(template_path)
    @values.fetch(template_path)
  end
end

class RenderTagTest < Minitest::Test
  include Liquid

  def test_render_with_no_arguments
    Liquid::Template.file_system = StubFileSystem.new('source' => 'rendered content')
    assert_template_result 'rendered content', "{% render 'source' %}"
  end

  def test_render_tag_looks_for_file_system_in_registers_first
    file_system = StubFileSystem.new('pick_a_source' => 'from register file system')
    assert_equal 'from register file system',
      Template.parse("{% render 'pick_a_source' %}").render!({}, registers: { file_system: file_system })
  end

  def test_render_passes_named_arguments_into_inner_scope
    Liquid::Template.file_system = StubFileSystem.new('product' => '{{ inner_product.title }}')
    assert_template_result 'My Product', "{% render 'product', inner_product: outer_product %}",
      'outer_product' => { 'title' => 'My Product' }
  end

  def test_render_accepts_literals_as_arguments
    Liquid::Template.file_system = StubFileSystem.new('snippet' => '{{ price }}')
    assert_template_result '123', "{% render 'snippet', price: 123 %}"
  end

  def test_render_accepts_multiple_named_arguments
    Liquid::Template.file_system = StubFileSystem.new('snippet' => '{{ one }} {{ two }}')
    assert_template_result '1 2', "{% render 'snippet', one: 1, two: 2 %}"
  end

  def test_render_does_inherit_parent_scope_variables
    Liquid::Template.file_system = StubFileSystem.new('snippet' => '{{ outer_variable }}')
    assert_template_result '', "{% render 'snippet' %}", 'outer_variable' => 'should not be visible'
  end

  def test_render_does_not_inherit_variable_with_same_name_as_snippet
    Liquid::Template.file_system = StubFileSystem.new('snippet' => '{{ snippet }}')
    assert_template_result '', "{% render 'snippet' %}", 'snippet' => 'should not be visible'
  end

  def test_render_sets_the_correct_template_name_for_errors
    Liquid::Template.file_system = StubFileSystem.new('snippet' => '{{ unsafe }}')
    Liquid::Template.taint_mode = :error

    template = Liquid::Template.parse("{% render 'snippet', unsafe: unsafe %}")
    template.render('unsafe' => String.new('unsafe').tap(&:taint))
    refute_empty template.errors

    assert_equal 'snippet', template.errors.first.template_name
  end

  def test_render_sets_the_correct_template_name_for_warnings
    Liquid::Template.file_system = StubFileSystem.new('snippet' => '{{ unsafe }}')
    Liquid::Template.taint_mode = :warn

    template = Liquid::Template.parse("{% render 'snippet', unsafe: unsafe %}")
    template.render('unsafe' => String.new('unsafe').tap(&:taint))
    refute_empty template.warnings

    assert_equal 'snippet', template.errors.first.template_name
  end

  def test_render_does_not_mutate_parent_scope
    Liquid::Template.file_system = StubFileSystem.new('snippet' => '{% assign inner = 1 %}')
    assert_template_result '', "{% render 'snippet' %}{{ inner }}"
  end

  def test_nested_render_tag
    Liquid::Template.file_system = StubFileSystem.new(
      'one' => "one {{ render 'two' }}",
      'two' => 'two'
    )
    assert_template_result 'one two', "{% include 'one' %}"
  end

  def test_nested_include_with_variable
    skip 'To be implemented'
    assert_template_result "Product: Draft 151cm details ",
      "{% include 'nested_product_template' with product %}", "product" => { "title" => 'Draft 151cm' }

    assert_template_result "Product: Draft 151cm details Product: Element 155cm details ",
      "{% include 'nested_product_template' for products %}", "products" => [{ "title" => 'Draft 151cm' }, { "title" => 'Element 155cm' }]
  end

  def test_recursively_included_template_does_not_produce_endless_loop
    skip 'To be implemented'
    infinite_file_system = Class.new do
      def read_template_file(template_path)
        "-{% include 'loop' %}"
      end
    end

    Liquid::Template.file_system = infinite_file_system.new

    assert_raises(Liquid::StackLevelError) do
      Template.parse("{% include 'loop' %}").render!
    end
  end

  def test_dynamically_choosen_template
    skip 'To be implemented'
    assert_template_result "Test123", "{% include template %}", "template" => 'Test123'
    assert_template_result "Test321", "{% include template %}", "template" => 'Test321'

    assert_template_result "Product: Draft 151cm ", "{% include template for product %}",
      "template" => 'product', 'product' => { 'title' => 'Draft 151cm' }
  end

  def test_include_tag_caches_second_read_of_same_partial
    skip 'To be implemented'
    file_system = CountingFileSystem.new
    assert_equal 'from CountingFileSystemfrom CountingFileSystem',
      Template.parse("{% include 'pick_a_source' %}{% include 'pick_a_source' %}").render!({}, registers: { file_system: file_system })
    assert_equal 1, file_system.count
  end

  def test_include_tag_doesnt_cache_partials_across_renders
    skip 'To be implemented'
    file_system = CountingFileSystem.new
    assert_equal 'from CountingFileSystem',
      Template.parse("{% include 'pick_a_source' %}").render!({}, registers: { file_system: file_system })
    assert_equal 1, file_system.count

    assert_equal 'from CountingFileSystem',
      Template.parse("{% include 'pick_a_source' %}").render!({}, registers: { file_system: file_system })
    assert_equal 2, file_system.count
  end

  def test_include_tag_within_if_statement
    skip 'To be implemented'
    assert_template_result "foo_if_true", "{% if true %}{% include 'foo_if_true' %}{% endif %}"
  end

  def test_custom_include_tag
    skip 'To be implemented'
    original_tag = Liquid::Template.tags['include']
    Liquid::Template.tags['include'] = CustomInclude
    begin
      assert_equal "custom_foo",
        Template.parse("{% include 'custom_foo' %}").render!
    ensure
      Liquid::Template.tags['include'] = original_tag
    end
  end

  def test_custom_include_tag_within_if_statement
    skip 'To be implemented'
    original_tag = Liquid::Template.tags['include']
    Liquid::Template.tags['include'] = CustomInclude
    begin
      assert_equal "custom_foo_if_true",
        Template.parse("{% if true %}{% include 'custom_foo_if_true' %}{% endif %}").render!
    ensure
      Liquid::Template.tags['include'] = original_tag
    end
  end

  def test_does_not_add_error_in_strict_mode_for_missing_variable
    skip 'To be implemented'
    Liquid::Template.file_system = TestFileSystem.new

    a = Liquid::Template.parse(' {% include "nested_template" %}')
    a.render!
    assert_empty a.errors
  end

  def test_passing_options_to_included_templates
    skip 'To be implemented'
    assert_raises(Liquid::SyntaxError) do
      Template.parse("{% include template %}", error_mode: :strict).render!("template" => '{{ "X" || downcase }}')
    end
    with_error_mode(:lax) do
      assert_equal 'x', Template.parse("{% include template %}", error_mode: :strict, include_options_blacklist: true).render!("template" => '{{ "X" || downcase }}')
    end
    assert_raises(Liquid::SyntaxError) do
      Template.parse("{% include template %}", error_mode: :strict, include_options_blacklist: [:locale]).render!("template" => '{{ "X" || downcase }}')
    end
    with_error_mode(:lax) do
      assert_equal 'x', Template.parse("{% include template %}", error_mode: :strict, include_options_blacklist: [:error_mode]).render!("template" => '{{ "X" || downcase }}')
    end
  end

  def test_render_raise_argument_error_when_template_is_undefined
    skip 'To be implemented'
    assert_raises(Liquid::ArgumentError) do
      template = Liquid::Template.parse('{% include undefined_variable %}')
      template.render!
    end
    assert_raises(Liquid::ArgumentError) do
      template = Liquid::Template.parse('{% include nil %}')
      template.render!
    end
  end

  def test_including_via_variable_value
    skip 'To be implemented'
    assert_template_result "from TestFileSystem", "{% assign page = 'pick_a_source' %}{% include page %}"

    assert_template_result "Product: Draft 151cm ", "{% assign page = 'product' %}{% include page %}", "product" => { 'title' => 'Draft 151cm' }

    assert_template_result "Product: Draft 151cm ", "{% assign page = 'product' %}{% include page for foo %}", "foo" => { 'title' => 'Draft 151cm' }
  end

  def test_including_with_strict_variables
    skip 'To be implemented'
    template = Liquid::Template.parse("{% include 'simple' %}", error_mode: :warn)
    template.render(nil, strict_variables: true)

    assert_equal [], template.errors
  end

  def test_break_through_include
    skip 'To be implemented'
    assert_template_result "1", "{% for i in (1..3) %}{{ i }}{% break %}{{ i }}{% endfor %}"
    assert_template_result "1", "{% for i in (1..3) %}{{ i }}{% include 'break' %}{{ i }}{% endfor %}"
  end
end # IncludeTagTest

