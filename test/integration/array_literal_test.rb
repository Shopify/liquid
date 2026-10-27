# frozen_string_literal: true

require 'test_helper'

class ArrayLiteralTest < Minitest::Test
  include Liquid

  module AppendFilter
    def append_item(input, item)
      input << item
    end
  end

  def test_empty_and_fixed_literals
    assert_template_result('0|', "{% assign rows = [] %}{{ rows.size }}|{{ rows | join: ',' }}")
    assert_template_result('top,bottom|2', "{% assign rows = ['top', 'bottom'] %}{{ rows | join: ',' }}|{{ rows.size }}")
  end

  def test_elements_are_full_expressions
    assert_template_result(
      '1|6|Shirt|lookup|B|true|1,2',
      "{% assign v = [1, values[1], product['title'], self['a'], missing or b, x == y, (1..2)] %}" \
        "{{ v | first }}|{{ v[1] }}|{{ v[2] }}|{{ v[3] }}|{{ v[4] }}|{{ v[5] }}|{{ v[6] | join: ',' }}",
      { 'values' => [5, 6], 'product' => { 'title' => 'Shirt' }, 'a' => 'lookup', 'b' => 'B', 'x' => 1, 'y' => 1 },
    )
  end

  def test_nested_literals_with_trailing_commas_and_whitespace
    template = "{% assign n = [\n\t[1,],\n  [ 2 , [] ,],\n] %}{{ n.size }}|{{ n[0].size }}|{{ n[1][0] }}|{{ n[1][1].size }}"
    assert_template_result('2|1|2|0', template)
  end

  def test_leading_bracket_constructs_a_literal_instead_of_a_bare_lookup
    assert_template_result('a|k', "{{ ['a'] }}|{{ [key] }}", { 'a' => 'lookup', 'key' => 'k', 'k' => 'v' })
  end

  def test_bracket_after_an_expression_stays_an_index_lookup
    assert_template_result('6|5|Shirt', "{{ values[1] }}|{{ values [0] }}|{{ product['title'] }}", {
      'values' => [5, 6],
      'product' => { 'title' => 'Shirt' },
    })
  end

  def test_malformed_literals_are_syntax_errors
    ['[1, , 2]', '[,]', '[1, 2,,]', '[1 2]', '[1, 2', '[1, 2][0]', '[1, 2].size', '[a: 1]'].each do |markup|
      assert_match_syntax_error(/\ALiquid syntax error/, "{{ #{markup} }}")
    end
  end

  def test_literals_work_in_expression_positions
    assert_template_result('a-b', "{% echo ['a', 'b'] | join: '-' %}")
    assert_template_result('1,2,3,4', "{{ list | concat: [3, 4], | join: ',' }}", { 'list' => [1, 2] })
    assert_template_result('false', "{{ flag | default: 'd', allow_false: [] }}", { 'flag' => false })
    assert_template_result('yes', "{% if [1, 2] contains 2 and [] %}yes{% endif %}")
    assert_template_result('match', "{% case list %}{% when [1, 2], [3] %}match{% endcase %}", { 'list' => [3] })
    assert_template_result('0=a;1=b;', "{% for item in fallback or ['a', 'b'] %}{{ forloop.index0 }}={{ item }};{% endfor %}")
    assert_template_result('12', "{% cycle [1, 2], 'b' %}")
  end

  def test_render_named_argument
    assert_template_result(
      '1,2,3',
      "{% render 'snip', coll: [a, b, c] %}",
      { 'a' => 1, 'b' => 2, 'c' => 3 },
      partials: { 'snip' => "{{ coll | join: ',' }}" },
    )
  end

  def test_render_for
    assert_template_result(
      '1,2,',
      "{% render 'snip' for [1, 2] as item %}",
      partials: { 'snip' => "{{ item }}," },
    )
  end

  def test_render_with
    assert_template_result(
      '1-2',
      "{% render 'snip' with [1, 2] as items %}",
      partials: { 'snip' => "{{ items | join: '-' }}" },
    )
  end

  def test_include_named_argument
    assert_template_result(
      '1,2',
      "{% include 'snip', coll: [1, 2] %}",
      partials: { 'snip' => "{{ coll | join: ',' }}" },
    )
  end

  def test_assign_score_matches_an_environment_array
    literal = Template.parse("{% assign a = [1, 2] %}")
    literal.render!
    environment_array = Template.parse("{% assign a = list %}")
    environment_array.render!({ 'list' => [1, 2] })

    assert_equal(3, literal.resource_limits.assign_score)
    assert_equal(environment_array.resource_limits.assign_score, literal.resource_limits.assign_score)
  end

  def test_assign_score_limit_applies_to_a_literal
    template = Template.parse("{% assign a = [1, 2] %}")
    template.resource_limits.assign_score_limit = 2
    assert_equal("Liquid error: Memory limits exceeded", template.render)
    assert(template.resource_limits.reached?)
  end

  def test_elements_evaluate_in_each_render_context
    template = Template.parse("{{ [a, [a]] | join: ',' }}", expression_cache: {})
    assert_equal('1,1', template.render!({ 'a' => 1 }))
    assert_equal('2,2', template.render!({ 'a' => 2 }))
  end

  def test_each_evaluation_returns_a_new_array
    environment = Environment.build { |env| env.register_filter(AppendFilter) }
    template = Template.parse(
      "{% for n in (1..2) %}{{ [1] | append_item: n | join: ',' }};{% endfor %}",
      environment: environment,
    )
    assert_equal('1,1;1,2;', template.render!)
    assert_equal('1,1;1,2;', template.render!)
  end

  def test_reversed_loop_leaves_the_literal_unchanged
    assert_template_result('321;321;', "{% for n in (1..2) %}{% for i in [1, 2, 3] reversed %}{{ i }}{% endfor %};{% endfor %}")
  end

  def test_host_expression_with_a_leading_bracket_is_an_array
    context = Context.new({ 'key' => 'name', 'name' => 'value' })
    assert_equal(['name'], context['[key]'])
    assert_equal([], context['[]'])
    assert_equal([1, ['name']], context['[1, [key]]'])
  end

  def test_host_self_lookup_reads_a_variable_by_name
    context = Context.new({ 'key' => 'name', 'name' => 'value' })
    assert_equal('value', context['self[key]'])
    assert_equal('value', context["self['name']"])
  end

  def test_for_single_element_literals
    assigns = { 'x' => 'name', 'name' => 'value', 'list' => [5, 6] }
    assert_template_result('1;', "{% for i in [1] %}{{ i }};{% endfor %}")
    assert_template_result('name;', "{% for i in [x] %}{{ i }};{% endfor %}", assigns)
    assert_template_result('', "{% for i in [] %}{{ i }};{% endfor %}")
    assert_template_result('1,2;3;', "{% for i in [[1, 2], 3] %}{{ i | join: ',' }};{% endfor %}")
    assert_template_result('6;', "{% for i in [list[1]] %}{{ i }};{% endfor %}", assigns)
    assert_template_result('7;8;', "{% for i in table[[1]] %}{{ i }};{% endfor %}", { 'table' => { [1] => [7, 8] } })
  end
end
