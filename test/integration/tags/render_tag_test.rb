# frozen_string_literal: true

require 'test_helper'

class RenderTagTest < Minitest::Test
  include Liquid

  def test_render_with_no_arguments
    Liquid::Template.file_system = StubFileSystem.new('source' => 'rendered content')
    assert_template_result('rendered content', '{% render "source" %}')
  end

  def test_render_tag_looks_for_file_system_in_registers_first
    file_system = StubFileSystem.new('pick_a_source' => 'from register file system')
    assert_equal('from register file system',
      Template.parse('{% render "pick_a_source" %}').render!({}, registers: { file_system: file_system }))
  end

  def test_render_passes_named_arguments_into_inner_scope
    Liquid::Template.file_system = StubFileSystem.new('product' => '{{ inner_product.title }}')
    assert_template_result('My Product', '{% render "product", inner_product: outer_product %}',
      'outer_product' => { 'title' => 'My Product' })
  end

  def test_render_accepts_literals_as_arguments
    Liquid::Template.file_system = StubFileSystem.new('snippet' => '{{ price }}')
    assert_template_result('123', '{% render "snippet", price: 123 %}')
  end

  def test_render_accepts_multiple_named_arguments
    Liquid::Template.file_system = StubFileSystem.new('snippet' => '{{ one }} {{ two }}')
    assert_template_result('1 2', '{% render "snippet", one: 1, two: 2 %}')
  end

  def test_render_does_not_inherit_parent_scope_variables
    Liquid::Template.file_system = StubFileSystem.new('snippet' => '{{ outer_variable }}')
    assert_template_result('', '{% assign outer_variable = "should not be visible" %}{% render "snippet" %}')
  end

  def test_render_does_not_inherit_variable_with_same_name_as_snippet
    Liquid::Template.file_system = StubFileSystem.new('snippet' => '{{ snippet }}')
    assert_template_result('', "{% assign snippet = 'should not be visible' %}{% render 'snippet' %}")
  end

  def test_render_does_not_mutate_parent_scope
    Liquid::Template.file_system = StubFileSystem.new('snippet' => '{% assign inner = 1 %}')
    assert_template_result('', "{% render 'snippet' %}{{ inner }}")
  end

  def test_nested_render_tag
    Liquid::Template.file_system = StubFileSystem.new(
      'one' => "one {% render 'two' %}",
      'two' => 'two'
    )
    assert_template_result('one two', "{% render 'one' %}")
  end

  def test_recursively_rendered_template_does_not_produce_endless_loop
    Liquid::Template.file_system = StubFileSystem.new('loop' => '{% render "loop" %}')

    assert_raises(Liquid::StackLevelError) do
      Template.parse('{% render "loop" %}').render!
    end
  end

  def test_sub_contexts_count_towards_the_same_recursion_limit
    Liquid::Template.file_system = StubFileSystem.new(
      'loop_render' => '{% render "loop_render" %}',
    )
    assert_raises(Liquid::StackLevelError) do
      Template.parse('{% render "loop_render" %}').render!
    end
  end

  def test_dynamically_choosen_templates_are_not_allowed
    Liquid::Template.file_system = StubFileSystem.new('snippet' => 'should not be rendered')

    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse("{% assign name = 'snippet' %}{% render name %}")
    end
  end

  def test_include_tag_caches_second_read_of_same_partial
    file_system = StubFileSystem.new('snippet' => 'echo')
    assert_equal('echoecho',
      Template.parse('{% render "snippet" %}{% render "snippet" %}')
      .render!({}, registers: { file_system: file_system }))
    assert_equal(1, file_system.file_read_count)
  end

  def test_render_tag_doesnt_cache_partials_across_renders
    file_system = StubFileSystem.new('snippet' => 'my message')

    assert_equal('my message',
      Template.parse('{% include "snippet" %}').render!({}, registers: { file_system: file_system }))
    assert_equal(1, file_system.file_read_count)

    assert_equal('my message',
      Template.parse('{% include "snippet" %}').render!({}, registers: { file_system: file_system }))
    assert_equal(2, file_system.file_read_count)
  end

  def test_render_tag_within_if_statement
    Liquid::Template.file_system = StubFileSystem.new('snippet' => 'my message')
    assert_template_result('my message', '{% if true %}{% render "snippet" %}{% endif %}')
  end

  def test_break_through_render
    Liquid::Template.file_system = StubFileSystem.new('break' => '{% break %}')
    assert_template_result('1', '{% for i in (1..3) %}{{ i }}{% break %}{{ i }}{% endfor %}')
    assert_template_result('112233', '{% for i in (1..3) %}{{ i }}{% render "break" %}{{ i }}{% endfor %}')
  end

  def test_increment_is_isolated_between_renders
    Liquid::Template.file_system = StubFileSystem.new('incr' => '{% increment %}')
    assert_template_result('010', '{% increment %}{% increment %}{% render "incr" %}')
  end

  def test_decrement_is_isolated_between_renders
    Liquid::Template.file_system = StubFileSystem.new('decr' => '{% decrement %}')
    assert_template_result('-1-2-1', '{% decrement %}{% decrement %}{% render "decr" %}')
  end

  def test_includes_will_not_render_inside_render_tag
    Liquid::Template.file_system = StubFileSystem.new(
      'foo' => 'bar',
      'test_include' => '{% include "foo" %}'
    )

    exc = assert_raises(Liquid::DisabledError) do
      Liquid::Template.parse('{% render "test_include" %}').render!
    end
    assert_equal('Liquid error: include usage is not allowed in this context', exc.message)
  end

  def test_includes_will_not_render_inside_nested_sibling_tags
    Liquid::Template.file_system = StubFileSystem.new(
      'foo' => 'bar',
      'nested_render_with_sibling_include' => '{% render "test_include" %}{% include "foo" %}',
      'test_include' => '{% include "foo" %}'
    )

    output = Liquid::Template.parse('{% render "nested_render_with_sibling_include" %}').render
    assert_equal('Liquid error: include usage is not allowed in this contextLiquid error: include usage is not allowed in this context', output)
  end

  def test_render_tag_with
    Liquid::Template.file_system = StubFileSystem.new(
      'product' => "Product: {{ product.title }} ",
      'product_alias' => "Product: {{ product.title }} ",
    )

    assert_template_result("Product: Draft 151cm ",
      "{% render 'product' with products[0] %}", "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }])
  end

  def test_render_tag_with_alias
    Liquid::Template.file_system = StubFileSystem.new(
      'product' => "Product: {{ product.title }} ",
      'product_alias' => "Product: {{ product.title }} ",
    )

    assert_template_result("Product: Draft 151cm ",
      "{% render 'product_alias' with products[0] as product %}", "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }])
  end

  def test_render_tag_for_alias
    Liquid::Template.file_system = StubFileSystem.new(
      'product' => "Product: {{ product.title }} ",
      'product_alias' => "Product: {{ product.title }} ",
    )

    assert_template_result("Product: Draft 151cm Product: Element 155cm ",
      "{% render 'product_alias' for products as product %}", "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }])
  end

  def test_render_tag_for
    Liquid::Template.file_system = StubFileSystem.new(
      'product' => "Product: {{ product.title }} ",
      'product_alias' => "Product: {{ product.title }} ",
    )

    assert_template_result("Product: Draft 151cm Product: Element 155cm ",
      "{% render 'product' for products %}", "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }])
  end

  def test_render_tag_forloop
    Liquid::Template.file_system = StubFileSystem.new(
      'product' => "Product: {{ product.title }} {% if forloop.first %}first{% endif %} {% if forloop.last %}last{% endif %} index:{{ forloop.index }} ",
    )

    assert_template_result("Product: Draft 151cm first  index:1 Product: Element 155cm  last index:2 ",
      "{% render 'product' for products %}", "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }])
  end

  def test_render_tag_for_drop
    Liquid::Template.file_system = StubFileSystem.new(
      'loop' => "{{ value.foo }}",
    )

    assert_template_result("123",
      "{% render 'loop' for loop as value %}", "loop" => TestEnumerable.new)
  end

  def test_render_tag_with_drop
    Liquid::Template.file_system = StubFileSystem.new(
      'loop' => "{{ value }}",
    )

    assert_template_result("TestEnumerable",
      "{% render 'loop' with loop as value %}", "loop" => TestEnumerable.new)
  end
end
