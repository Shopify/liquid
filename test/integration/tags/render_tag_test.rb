# frozen_string_literal: true

require 'test_helper'

class RenderTagTest < Minitest::Test
  include Liquid

  def test_render_with_no_arguments
    assert_template_result('rendered content', '{% render "source" %}',
      partials: { 'source' => 'rendered content' })
  end

  def test_render_tag_looks_for_file_system_in_registers_first
    assert_template_result('from register file system', '{% render "pick_a_source" %}',
      partials: { 'pick_a_source' => 'from register file system' })
  end

  def test_render_passes_named_arguments_into_inner_scope
    assert_template_result('My Product', '{% render "product", inner_product: outer_product %}',
      { 'outer_product' => { 'title' => 'My Product' } },
      partials: { 'product' => '{{ inner_product.title }}' })
  end

  def test_render_accepts_literals_as_arguments
    assert_template_result('123', '{% render "snippet", price: 123 %}',
      partials: { 'snippet' => '{{ price }}' })
  end

  def test_render_accepts_multiple_named_arguments
    assert_template_result('1 2', '{% render "snippet", one: 1, two: 2 %}',
      partials: { 'snippet' => '{{ one }} {{ two }}' })
  end

  def test_render_does_not_inherit_parent_scope_variables
    assert_template_result('', '{% assign outer_variable = "should not be visible" %}{% render "snippet" %}',
      partials: { 'snippet' => '{{ outer_variable }}' })
  end

  def test_render_does_not_inherit_variable_with_same_name_as_snippet
    assert_template_result('', "{% assign snippet = 'should not be visible' %}{% render 'snippet' %}",
      partials: { 'snippet' => '{{ snippet }}' })
  end

  def test_render_does_not_mutate_parent_scope
    assert_template_result('', "{% render 'snippet' %}{{ inner }}",
      partials: { 'snippet' => '{% assign inner = 1 %}' })
  end

  def test_nested_render_tag
    assert_template_result('one two', "{% render 'one' %}",
      partials: {
        'one' => "one {% render 'two' %}",
        'two' => 'two',
      })
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
    assert_syntax_error("{% assign name = 'snippet' %}{% render name %}")
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
    assert_template_result('my message', '{% if true %}{% render "snippet" %}{% endif %}',
      partials: { 'snippet' => 'my message' })
  end

  def test_break_through_render
    options = { partials: { 'break' => '{% break %}' } }
    assert_template_result('1', '{% for i in (1..3) %}{{ i }}{% break %}{{ i }}{% endfor %}', **options)
    assert_template_result('112233', '{% for i in (1..3) %}{{ i }}{% render "break" %}{{ i }}{% endfor %}', **options)
  end

  def test_increment_is_isolated_between_renders
    assert_template_result('010', '{% increment %}{% increment %}{% render "incr" %}',
      partials: { 'incr' => '{% increment %}' })
  end

  def test_decrement_is_isolated_between_renders
    assert_template_result('-1-2-1', '{% decrement %}{% decrement %}{% render "decr" %}',
      partials: { 'decr' => '{% decrement %}' })
  end

  def test_includes_will_not_render_inside_render_tag
    assert_template_result(
      'Liquid error (test_include line 1): include usage is not allowed in this context',
      '{% render "test_include" %}',
      render_errors: true,
      partials: {
        'foo' => 'bar',
        'test_include' => '{% include "foo" %}',
      }
    )
  end

  def test_includes_will_not_render_inside_nested_sibling_tags
    assert_template_result(
      "Liquid error (test_include line 1): include usage is not allowed in this context" \
        "Liquid error (nested_render_with_sibling_include line 1): include usage is not allowed in this context",
      '{% render "nested_render_with_sibling_include" %}',
      partials: {
        'foo' => 'bar',
        'nested_render_with_sibling_include' => '{% render "test_include" %}{% include "foo" %}',
        'test_include' => '{% include "foo" %}',
      },
      render_errors: true
    )
  end

  def test_render_tag_with
    assert_template_result("Product: Draft 151cm ",
      "{% render 'product' with products[0] %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: {
        'product' => "Product: {{ product.title }} ",
        'product_alias' => "Product: {{ product.title }} ",
      })
  end

  def test_render_tag_with_alias
    assert_template_result("Product: Draft 151cm ",
      "{% render 'product_alias' with products[0] as product %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: {
        'product' => "Product: {{ product.title }} ",
        'product_alias' => "Product: {{ product.title }} ",
      })
  end

  def test_render_tag_for_alias
    assert_template_result("Product: Draft 151cm Product: Element 155cm ",
      "{% render 'product_alias' for products as product %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: {
        'product' => "Product: {{ product.title }} ",
        'product_alias' => "Product: {{ product.title }} ",
      })
  end

  def test_render_tag_for
    assert_template_result("Product: Draft 151cm Product: Element 155cm ",
      "{% render 'product' for products %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: {
        'product' => "Product: {{ product.title }} ",
        'product_alias' => "Product: {{ product.title }} ",
      })
  end

  def test_render_tag_forloop
    assert_template_result("Product: Draft 151cm first  index:1 Product: Element 155cm  last index:2 ",
      "{% render 'product' for products %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: {
        'product' => "Product: {{ product.title }} {% if forloop.first %}first{% endif %} {% if forloop.last %}last{% endif %} index:{{ forloop.index }} ",
      })
  end

  def test_render_tag_for_drop
    assert_template_result("123",
      "{% render 'loop' for loop as value %}", { "loop" => TestEnumerable.new },
      partials: {
        'loop' => "{{ value.foo }}",
      })
  end

  def test_render_tag_with_drop
    assert_template_result("TestEnumerable",
      "{% render 'loop' with loop as value %}", { "loop" => TestEnumerable.new },
      partials: {
        'loop' => "{{ value }}",
      })
  end
end
