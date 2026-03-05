# frozen_string_literal: true

require 'test_helper'

class RenderTagTest < Minitest::Test
  include Liquid

  def test_render_with_no_arguments
    assert_template_result(
      'rendered content',
      '{% render "source" %}',
      partials: { 'source' => 'rendered content' },
    )
  end

  def test_render_tag_looks_for_file_system_in_registers_first
    assert_template_result(
      'from register file system',
      '{% render "pick_a_source" %}',
      partials: { 'pick_a_source' => 'from register file system' },
    )
  end

  def test_render_passes_named_arguments_into_inner_scope
    assert_template_result(
      'My Product',
      '{% render "product", inner_product: outer_product %}',
      { 'outer_product' => { 'title' => 'My Product' } },
      partials: { 'product' => '{{ inner_product.title }}' },
    )
  end

  def test_render_accepts_literals_as_arguments
    assert_template_result(
      '123',
      '{% render "snippet", price: 123 %}',
      partials: { 'snippet' => '{{ price }}' },
    )
  end

  def test_render_accepts_multiple_named_arguments
    assert_template_result(
      '1 2',
      '{% render "snippet", one: 1, two: 2 %}',
      partials: { 'snippet' => '{{ one }} {{ two }}' },
    )
  end

  def test_render_does_not_inherit_parent_scope_variables
    assert_template_result(
      '',
      '{% assign outer_variable = "should not be visible" %}{% render "snippet" %}',
      partials: { 'snippet' => '{{ outer_variable }}' },
    )
  end

  def test_render_does_not_inherit_variable_with_same_name_as_snippet
    assert_template_result(
      '',
      "{% assign snippet = 'should not be visible' %}{% render 'snippet' %}",
      partials: { 'snippet' => '{{ snippet }}' },
    )
  end

  def test_render_does_not_mutate_parent_scope
    assert_template_result(
      '',
      "{% render 'snippet' %}{{ inner }}",
      partials: { 'snippet' => '{% assign inner = 1 %}' },
    )
  end

  def test_nested_render_tag
    assert_template_result(
      'one two',
      "{% render 'one' %}",
      partials: {
        'one' => "one {% render 'two' %}",
        'two' => 'two',
      },
    )
  end

  def test_recursively_rendered_template_does_not_produce_endless_loop
    env = Liquid::Environment.build(
      file_system: StubFileSystem.new('loop' => '{% render "loop" %}'),
    )

    assert_raises(Liquid::StackLevelError) do
      Template.parse('{% render "loop" %}', environment: env).render!
    end
  end

  def test_sub_contexts_count_towards_the_same_recursion_limit
    env = Liquid::Environment.build(
      file_system: StubFileSystem.new('loop_render' => '{% render "loop_render" %}'),
    )

    assert_raises(Liquid::StackLevelError) do
      Template.parse('{% render "loop_render" %}', environment: env).render!
    end
  end

  def test_dynamically_choosen_templates_are_not_allowed
    assert_syntax_error("{% assign name = 'snippet' %}{% render name %}")
  end

  def test_strict2_parsing_errors
    with_error_modes(:lax, :strict) do
      assert_template_result(
        'hello value1 value2',
        '{% render "snippet" !!! arg1: "value1" ~~~ arg2: "value2" %}',
        partials: { 'snippet' => 'hello {{ arg1 }} {{ arg2 }}' },
      )
    end

    with_error_modes(:strict2) do
      assert_syntax_error(
        '{% render "snippet" !!! arg1: "value1" ~~~ arg2: "value2" %}',
      )
      assert_syntax_error(
        '{% render "snippet" | filter %}',
      )
    end
  end

  def test_optional_commas
    partials = { 'snippet' => 'hello {{ arg1 }} {{ arg2 }}' }
    assert_template_result('hello value1 value2', '{% render "snippet", arg1: "value1", arg2: "value2" %}', partials: partials)
    assert_template_result('hello value1 value2', '{% render "snippet"  arg1: "value1", arg2: "value2" %}', partials: partials)
    assert_template_result('hello value1 value2', '{% render "snippet"  arg1: "value1"  arg2: "value2" %}', partials: partials)
  end

  def test_render_tag_caches_second_read_of_same_partial
    file_system = StubFileSystem.new('snippet' => 'echo')
    assert_equal(
      'echoecho',
      Template.parse('{% render "snippet" %}{% render "snippet" %}')
      .render!({}, registers: { file_system: file_system }),
    )
    assert_equal(1, file_system.file_read_count)
  end

  def test_render_tag_doesnt_cache_partials_across_renders
    file_system = StubFileSystem.new('snippet' => 'my message')

    assert_equal(
      'my message',
      Template.parse('{% include "snippet" %}').render!({}, registers: { file_system: file_system }),
    )
    assert_equal(1, file_system.file_read_count)

    assert_equal(
      'my message',
      Template.parse('{% include "snippet" %}').render!({}, registers: { file_system: file_system }),
    )
    assert_equal(2, file_system.file_read_count)
  end

  def test_render_tag_within_if_statement
    assert_template_result(
      'my message',
      '{% if true %}{% render "snippet" %}{% endif %}',
      partials: { 'snippet' => 'my message' },
    )
  end

  def test_break_through_render
    options = { partials: { 'break' => '{% break %}' } }
    assert_template_result('1', '{% for i in (1..3) %}{{ i }}{% break %}{{ i }}{% endfor %}', **options)
    assert_template_result('112233', '{% for i in (1..3) %}{{ i }}{% render "break" %}{{ i }}{% endfor %}', **options)
  end

  def test_increment_is_isolated_between_renders
    assert_template_result(
      '010',
      '{% increment %}{% increment %}{% render "incr" %}',
      partials: { 'incr' => '{% increment %}' },
    )
  end

  def test_decrement_is_isolated_between_renders
    assert_template_result(
      '-1-2-1',
      '{% decrement %}{% decrement %}{% render "decr" %}',
      partials: { 'decr' => '{% decrement %}' },
    )
  end

  def test_includes_will_not_render_inside_render_tag
    assert_template_result(
      'Liquid error (test_include line 1): include usage is not allowed in this context',
      '{% render "test_include" %}',
      render_errors: true,
      partials: {
        'foo' => 'bar',
        'test_include' => '{% include "foo" %}',
      },
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
      render_errors: true,
    )
  end

  def test_render_tag_with
    assert_template_result(
      "Product: Draft 151cm ",
      "{% render 'product' with products[0] %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: {
        'product' => "Product: {{ product.title }} ",
        'product_alias' => "Product: {{ product.title }} ",
      },
    )
  end

  def test_render_tag_with_alias
    assert_template_result(
      "Product: Draft 151cm ",
      "{% render 'product_alias' with products[0] as product %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: {
        'product' => "Product: {{ product.title }} ",
        'product_alias' => "Product: {{ product.title }} ",
      },
    )
  end

  def test_render_tag_for_alias
    assert_template_result(
      "Product: Draft 151cm Product: Element 155cm ",
      "{% render 'product_alias' for products as product %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: {
        'product' => "Product: {{ product.title }} ",
        'product_alias' => "Product: {{ product.title }} ",
      },
    )
  end

  def test_render_tag_for
    assert_template_result(
      "Product: Draft 151cm Product: Element 155cm ",
      "{% render 'product' for products %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: {
        'product' => "Product: {{ product.title }} ",
        'product_alias' => "Product: {{ product.title }} ",
      },
    )
  end

  def test_render_tag_forloop
    assert_template_result(
      "Product: Draft 151cm first  index:1 Product: Element 155cm  last index:2 ",
      "{% render 'product' for products %}",
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: {
        'product' => "Product: {{ product.title }} {% if forloop.first %}first{% endif %} {% if forloop.last %}last{% endif %} index:{{ forloop.index }} ",
      },
    )
  end

  # FIXME
  def skip_test_render_tag_for_drop
    assert_template_result(
      "123",
      "{% render 'loop' for loop as value %}",
      { "loop" => TestEnumerable.new },
      partials: {
        'loop' => "{{ value.foo }}",
      },
    )
  end

  # FIXME
  def skip_test_render_tag_with_drop
    assert_template_result(
      "TestEnumerable",
      "{% render 'loop' with loop as value %}",
      { "loop" => TestEnumerable.new },
      partials: {
        'loop' => "{{ value }}",
      },
    )
  end

  def test_render_tag_renders_error_with_template_name
    assert_template_result(
      'Liquid error (foo line 1): standard error',
      "{% render 'foo' with errors %}",
      { 'errors' => ErrorDrop.new },
      partials: { 'foo' => '{{ foo.standard_error }}' },
      render_errors: true,
    )
  end

  def test_render_tag_renders_error_with_template_name_from_template_factory
    assert_template_result(
      'Liquid error (some/path/foo line 1): standard error',
      "{% render 'foo' with errors %}",
      { 'errors' => ErrorDrop.new },
      partials: { 'foo' => '{{ foo.standard_error }}' },
      template_factory: StubTemplateFactory.new,
      render_errors: true,
    )
  end

  def test_render_with_invalid_expression
    template = '{% render "snippet" with foo=>bar %}'

    with_error_modes(:lax, :strict) do
      refute_nil(Template.parse(template))
    end

    with_error_modes(:strict2) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }
      assert_match(/Unexpected character =/, error.message)
    end
  end

  def test_render_attribute_with_invalid_expression
    template = '{% render "snippet", key: foo=>bar %}'

    with_error_modes(:lax, :strict) do
      refute_nil(Template.parse(template))
    end

    with_error_modes(:strict2) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }
      assert_match(/Unexpected character =/, error.message)
    end
  end

  # Block form tests

  def test_render_block_form_passes_content_to_snippet
    assert_template_result(
      'Hello',
      '{% render "snippet" %}Hello{% endrender %}',
      partials: { 'snippet' => '{{ content }}' },
    )
  end

  def test_render_block_form_with_outer_variable
    assert_template_result(
      'world',
      '{% render "snippet" %}{{ greeting }}{% endrender %}',
      { 'greeting' => 'world' },
      partials: { 'snippet' => '{{ content }}' },
    )
  end

  def test_render_block_form_empty_body
    assert_template_result(
      '',
      '{% render "snippet" %}{% endrender %}',
      partials: { 'snippet' => '{{ content }}' },
    )
  end

  def test_render_block_form_with_named_arguments
    assert_template_result(
      'Hello world',
      '{% render "snippet", greeting: "world" %}Hello{% endrender %}',
      partials: { 'snippet' => '{{ content }} {{ greeting }}' },
    )
  end

  def test_render_block_form_with_for_parameter
    assert_template_result(
      'Product: Draft 151cm [body] Product: Element 155cm [body] ',
      '{% render "product" for products %}[body]{% endrender %}',
      { "products" => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }] },
      partials: {
        'product' => 'Product: {{ product.title }} {{ content }} ',
      },
    )
  end

  def test_render_block_form_with_with_parameter
    assert_template_result(
      'Product: Draft 151cm [body]',
      "{% render 'product' with products[0] %}[body]{% endrender %}",
      { "products" => [{ 'title' => 'Draft 151cm' }] },
      partials: {
        'product' => 'Product: {{ product.title }} {{ content }}',
      },
    )
  end

  def test_render_block_form_content_does_not_leak_to_outer_scope
    assert_template_result(
      'Hello',
      '{% render "snippet" %}Hello{% endrender %}{{ content }}',
      partials: { 'snippet' => '{{ content }}' },
    )
  end

  def test_render_block_form_content_does_not_conflict_with_user_variable
    assert_template_result(
      'body user_value',
      '{% render "snippet", user_content: "user_value" %}body{% endrender %}',
      partials: { 'snippet' => '{{ content }} {{ user_content }}' },
    )
  end

  def test_render_block_form_content_does_not_override_explicit_content_attribute
    assert_template_result(
      'explicit',
      '{% render "snippet", content: "explicit" %}body{% endrender %}',
      partials: { 'snippet' => '{{ content }}' },
    )
  end

  def test_render_block_form_nested
    assert_template_result(
      'inner',
      '{% render "outer" %}{% render "inner" %}inner{% endrender %}{% endrender %}',
      partials: {
        'outer' => '{{ content }}',
        'inner' => '{{ content }}',
      },
    )
  end

  def test_render_block_form_snippet_cannot_access_outer_variables
    assert_template_result(
      'body',
      '{% assign secret = "hidden" %}{% render "snippet" %}body{% endrender %}',
      partials: { 'snippet' => '{{ content }}{{ secret }}' },
    )
  end

  def test_self_closing_render_still_works
    assert_template_result(
      'rendered content',
      '{% render "source" %}',
      partials: { 'source' => 'rendered content' },
    )
  end

  # Deep nesting tests

  def test_render_block_form_deeply_nested_three_levels
    assert_template_result(
      'innermost',
      '{% render "a" %}{% render "b" %}{% render "c" %}innermost{% endrender %}{% endrender %}{% endrender %}',
      partials: {
        'a' => '{{ content }}',
        'b' => '{{ content }}',
        'c' => '{{ content }}',
      },
    )
  end

  def test_render_block_form_deeply_nested_with_surrounding_text
    assert_template_result(
      'a[b[c[deep]c]b]a',
      '{% render "a" %}{% render "b" %}{% render "c" %}deep{% endrender %}{% endrender %}{% endrender %}',
      partials: {
        'a' => 'a[{{ content }}]a',
        'b' => 'b[{{ content }}]b',
        'c' => 'c[{{ content }}]c',
      },
    )
  end

  # Block-form render inside {% liquid %} tag

  def test_render_block_form_inside_liquid_tag_raises_syntax_error
    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse("{% liquid\n  render \"snippet\"\n  endrender\n%}")
    end
  end

  # Block-form render inside for loop

  def test_render_block_form_inside_for_loop
    assert_template_result(
      'item: a item: b item: c ',
      '{% for item in items %}{% render "snippet" %}item: {{ item }}{% endrender %} {% endfor %}',
      { 'items' => ['a', 'b', 'c'] },
      partials: { 'snippet' => '{{ content }}' },
    )
  end

  def test_render_block_form_inside_for_loop_with_forloop_variable
    assert_template_result(
      '1:a 2:b 3:c ',
      '{% for item in items %}{% render "snippet" %}{{ forloop.index }}:{{ item }}{% endrender %} {% endfor %}',
      { 'items' => ['a', 'b', 'c'] },
      partials: { 'snippet' => '{{ content }}' },
    )
  end

  # Self-closing and block-form interleaved

  def test_self_closing_and_block_form_interleaved
    assert_template_result(
      'self-closingblock-contentself-closing',
      '{% render "snippet" %}{% render "snippet" %}block-content{% endrender %}{% render "snippet" %}',
      partials: { 'snippet' => '{% if content %}{{ content }}{% else %}self-closing{% endif %}' },
    )
  end

  def test_block_form_then_self_closing_then_block_form
    assert_template_result(
      'first self-closing second',
      '{% render "snippet" %}first{% endrender %} {% render "snippet" %} {% render "snippet" %}second{% endrender %}',
      partials: { 'snippet' => '{% if content %}{{ content }}{% else %}self-closing{% endif %}' },
    )
  end

  # Content not used by snippet

  def test_render_block_form_content_ignored_when_snippet_does_not_use_it
    assert_template_result(
      'static output',
      '{% render "snippet" %}this body is ignored{% endrender %}',
      partials: { 'snippet' => 'static output' },
    )
  end

  # Scope isolation: assign/capture in body

  def test_render_block_form_body_assign_stays_in_outer_scope
    assert_template_result(
      'from-body',
      '{% render "snippet" %}{% assign x = "from-body" %}{% endrender %}{{ x }}',
      partials: { 'snippet' => '{{ content }}' },
    )
  end

  def test_render_block_form_body_assign_not_visible_inside_snippet
    assert_template_result(
      '',
      '{% render "snippet" %}{% assign leaked = "secret" %}{% endrender %}',
      partials: { 'snippet' => '{{ content }}{{ leaked }}' },
    )
  end

  def test_render_block_form_body_capture_stays_in_outer_scope
    assert_template_result(
      'captured-value',
      '{% render "snippet" %}{% capture val %}captured-value{% endcapture %}{% endrender %}{{ val }}',
      partials: { 'snippet' => '{{ content }}' },
    )
  end

  def test_render_block_form_body_capture_not_visible_inside_snippet
    assert_template_result(
      '',
      '{% render "snippet" %}{% capture leaked %}secret{% endcapture %}{% endrender %}',
      partials: { 'snippet' => '{{ content }}{{ leaked }}' },
    )
  end

  # Block-form render with for: parameter and body referencing outer scope variables

  def test_render_block_form_for_parameter_body_accesses_outer_variable
    assert_template_result(
      'Draft 151cm (sale)Element 155cm (sale) ',
      '{% render "product" for products %}({{ label }}){% endrender %} ',
      { 'products' => [{ 'title' => 'Draft 151cm' }, { 'title' => 'Element 155cm' }], 'label' => 'sale' },
      partials: {
        'product' => '{{ product.title }} {{ content }}',
      },
    )
  end

  # Error cases

  def test_render_block_form_mismatched_end_tag
    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse('{% render "snippet" %}body{% endif %}')
    end
  end

  def test_render_block_form_unclosed
    # Without a matching endrender, this is treated as self-closing
    # and trailing text is rendered as literal output
    assert_template_result(
      'hellotrailing text',
      '{% render "snippet" %}trailing text',
      partials: { 'snippet' => 'hello' },
    )
  end
end
