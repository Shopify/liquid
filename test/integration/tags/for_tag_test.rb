# frozen_string_literal: true

require 'test_helper'

class ThingWithValue < Liquid::Drop
  def value
    3
  end
end

class ForTagTest < Minitest::Test
  include Liquid

  def test_for
    assert_template_result(' yo  yo  yo  yo ', '{%for item in array%} yo {%endfor%}', { 'array' => [1, 2, 3, 4] })
    assert_template_result('yoyo', '{%for item in array%}yo{%endfor%}', { 'array' => [1, 2] })
    assert_template_result(' yo ', '{%for item in array%} yo {%endfor%}', { 'array' => [1] })
    assert_template_result('', '{%for item in array%}{%endfor%}', { 'array' => [1, 2] })
    expected = <<HERE

  yo

  yo

  yo

HERE
    template = <<~HERE
      {%for item in array%}
        yo
      {%endfor%}
    HERE
    assert_template_result(expected, template, { 'array' => [1, 2, 3] })
  end

  def test_for_reversed
    assigns = { 'array' => [1, 2, 3] }
    assert_template_result('321', '{%for item in array reversed %}{{item}}{%endfor%}', assigns)
  end

  def test_for_with_range
    assert_template_result(' 1  2  3 ', '{%for item in (1..3) %} {{item}} {%endfor%}')

    assert_raises(Liquid::ArgumentError) do
      Template.parse('{% for i in (a..2) %}{% endfor %}').render!("a" => [1, 2])
    end

    assert_template_result(' 0  1  2  3 ', '{% for item in (a..3) %} {{item}} {% endfor %}', { "a" => "invalid integer" })
  end

  def test_for_with_variable_range
    assert_template_result(' 1  2  3 ', '{%for item in (1..foobar) %} {{item}} {%endfor%}', { "foobar" => 3 })
  end

  def test_for_with_hash_value_range
    foobar = { "value" => 3 }
    assert_template_result(' 1  2  3 ', '{%for item in (1..foobar.value) %} {{item}} {%endfor%}', { "foobar" => foobar })
  end

  def test_for_with_drop_value_range
    foobar = ThingWithValue.new
    assert_template_result(' 1  2  3 ', '{%for item in (1..foobar.value) %} {{item}} {%endfor%}', { "foobar" => foobar })
  end

  def test_for_with_variable
    assert_template_result(' 1  2  3 ', '{%for item in array%} {{item}} {%endfor%}', { 'array' => [1, 2, 3] })
    assert_template_result('123', '{%for item in array%}{{item}}{%endfor%}', { 'array' => [1, 2, 3] })
    assert_template_result('123', '{% for item in array %}{{item}}{% endfor %}', { 'array' => [1, 2, 3] })
    assert_template_result('abcd', '{%for item in array%}{{item}}{%endfor%}', { 'array' => ['a', 'b', 'c', 'd'] })
    assert_template_result('a b c', '{%for item in array%}{{item}}{%endfor%}', { 'array' => ['a', ' ', 'b', ' ', 'c'] })
    assert_template_result('abc', '{%for item in array%}{{item}}{%endfor%}', { 'array' => ['a', '', 'b', '', 'c'] })
  end

  def test_for_helpers
    assigns = { 'array' => [1, 2, 3] }
    assert_template_result(
      ' 1/3  2/3  3/3 ',
      '{%for item in array%} {{forloop.index}}/{{forloop.length}} {%endfor%}',
      assigns,
    )
    assert_template_result(' 1  2  3 ', '{%for item in array%} {{forloop.index}} {%endfor%}', assigns)
    assert_template_result(' 0  1  2 ', '{%for item in array%} {{forloop.index0}} {%endfor%}', assigns)
    assert_template_result(' 2  1  0 ', '{%for item in array%} {{forloop.rindex0}} {%endfor%}', assigns)
    assert_template_result(' 3  2  1 ', '{%for item in array%} {{forloop.rindex}} {%endfor%}', assigns)
    assert_template_result(' true  false  false ', '{%for item in array%} {{forloop.first}} {%endfor%}', assigns)
    assert_template_result(' false  false  true ', '{%for item in array%} {{forloop.last}} {%endfor%}', assigns)
  end

  def test_for_and_if
    assigns = { 'array' => [1, 2, 3] }
    assert_template_result(
      '+--',
      '{%for item in array%}{% if forloop.first %}+{% else %}-{% endif %}{%endfor%}',
      assigns,
    )
  end

  def test_for_else
    assert_template_result('+++', '{%for item in array%}+{%else%}-{%endfor%}', { 'array' => [1, 2, 3] })
    assert_template_result('-',   '{%for item in array%}+{%else%}-{%endfor%}', { 'array' => [] })
    assert_template_result('-',   '{%for item in array%}+{%else%}-{%endfor%}', { 'array' => nil })
  end

  def test_limiting
    assigns = { 'array' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] }
    assert_template_result('12', '{%for i in array limit:2 %}{{ i }}{%endfor%}', assigns)
    assert_template_result('1234', '{%for i in array limit:4 %}{{ i }}{%endfor%}', assigns)
    assert_template_result('3456', '{%for i in array limit:4 offset:2 %}{{ i }}{%endfor%}', assigns)
    assert_template_result('3456', '{%for i in array limit: 4 offset: 2 %}{{ i }}{%endfor%}', assigns)
    assert_template_result('3456', '{%for i in array, limit: 4, offset: 2 %}{{ i }}{%endfor%}', assigns)
  end

  def test_limiting_with_invalid_limit
    assigns  = { 'array' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] }
    template = <<-MKUP
      {% for i in array limit: true offset: 1 %}
        {{ i }}
      {% endfor %}
    MKUP

    exception = assert_raises(Liquid::ArgumentError) do
      Template.parse(template).render!(assigns)
    end
    assert_equal("Liquid error: invalid integer", exception.message)
  end

  def test_limiting_with_invalid_offset
    assigns  = { 'array' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] }
    template = <<-MKUP
      {% for i in array limit: 1 offset: true %}
        {{ i }}
      {% endfor %}
    MKUP

    exception = assert_raises(Liquid::ArgumentError) do
      Template.parse(template).render!(assigns)
    end
    assert_equal("Liquid error: invalid integer", exception.message)
  end

  def test_dynamic_variable_limiting
    assigns           = { 'array' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] }
    assigns['limit']  = 2
    assigns['offset'] = 2

    assert_template_result('34', '{%for i in array limit: limit offset: offset %}{{ i }}{%endfor%}', assigns)
  end

  def test_nested_for
    assigns = { 'array' => [[1, 2], [3, 4], [5, 6]] }
    assert_template_result('123456', '{%for item in array%}{%for i in item%}{{ i }}{%endfor%}{%endfor%}', assigns)
  end

  def test_offset_only
    assigns = { 'array' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] }
    assert_template_result('890', '{%for i in array offset:7 %}{{ i }}{%endfor%}', assigns)
  end

  def test_pause_resume
    assigns  = { 'array' => { 'items' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] } }
    markup   = <<-MKUP
      {%for i in array.items limit: 3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit: 3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit: 3 %}{{i}}{%endfor%}
      MKUP
    expected = <<-XPCTD
      123
      next
      456
      next
      789
      XPCTD
    assert_template_result(expected, markup, assigns)
  end

  def test_pause_resume_limit
    assigns  = { 'array' => { 'items' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] } }
    markup   = <<-MKUP
      {%for i in array.items limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:1 %}{{i}}{%endfor%}
      MKUP
    expected = <<-XPCTD
      123
      next
      456
      next
      7
      XPCTD
    assert_template_result(expected, markup, assigns)
  end

  def test_pause_resume_big_limit
    assigns  = { 'array' => { 'items' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] } }
    markup   = <<-MKUP
      {%for i in array.items limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:1000 %}{{i}}{%endfor%}
      MKUP
    expected = <<-XPCTD
      123
      next
      456
      next
      7890
      XPCTD
    assert_template_result(expected, markup, assigns)
  end

  def test_pause_resume_big_offset
    assigns  = { 'array' => { 'items' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] } }
    markup   = '{%for i in array.items limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:3 offset:1000 %}{{i}}{%endfor%}'
    expected = '123
      next
      456
      next
      '
    assert_template_result(expected, markup, assigns)
  end

  def test_for_with_break
    assigns = { 'array' => { 'items' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] } }

    markup   = '{% for i in array.items %}{% break %}{% endfor %}'
    expected = ""
    assert_template_result(expected, markup, assigns)

    markup   = '{% for i in array.items %}{{ i }}{% break %}{% endfor %}'
    expected = "1"
    assert_template_result(expected, markup, assigns)

    markup   = '{% for i in array.items %}{% break %}{{ i }}{% endfor %}'
    expected = ""
    assert_template_result(expected, markup, assigns)

    markup   = '{% for i in array.items %}{{ i }}{% if i > 3 %}{% break %}{% endif %}{% endfor %}'
    expected = "1234"
    assert_template_result(expected, markup, assigns)

    # tests to ensure it only breaks out of the local for loop
    # and not all of them.
    assigns  = { 'array' => [[1, 2], [3, 4], [5, 6]] }
    markup   = '{% for item in array %}' \
               '{% for i in item %}' \
                 '{% if i == 1 %}' \
                   '{% break %}' \
                 '{% endif %}' \
                 '{{ i }}' \
               '{% endfor %}' \
             '{% endfor %}'
    expected = '3456'
    assert_template_result(expected, markup, assigns)

    # test break does nothing when unreached
    assigns  = { 'array' => { 'items' => [1, 2, 3, 4, 5] } }
    markup   = '{% for i in array.items %}{% if i == 9999 %}{% break %}{% endif %}{{ i }}{% endfor %}'
    expected = '12345'
    assert_template_result(expected, markup, assigns)
  end

  def test_for_with_break_after_nested_loop
    source = <<~LIQUID.chomp
      {% for i in (1..2) -%}
        {% for j in (1..2) -%}
          {{ i }}-{{ j }},
        {%- endfor -%}
        {% break -%}
      {% endfor -%}
      after
    LIQUID
    assert_template_result("1-1,1-2,after", source)
  end

  def test_for_with_continue
    assigns = { 'array' => { 'items' => [1, 2, 3, 4, 5] } }

    markup   = '{% for i in array.items %}{% continue %}{% endfor %}'
    expected = ""
    assert_template_result(expected, markup, assigns)

    markup   = '{% for i in array.items %}{{ i }}{% continue %}{% endfor %}'
    expected = "12345"
    assert_template_result(expected, markup, assigns)

    markup   = '{% for i in array.items %}{% continue %}{{ i }}{% endfor %}'
    expected = ""
    assert_template_result(expected, markup, assigns)

    markup   = '{% for i in array.items %}{% if i > 3 %}{% continue %}{% endif %}{{ i }}{% endfor %}'
    expected = "123"
    assert_template_result(expected, markup, assigns)

    markup   = '{% for i in array.items %}{% if i == 3 %}{% continue %}{% else %}{{ i }}{% endif %}{% endfor %}'
    expected = "1245"
    assert_template_result(expected, markup, assigns)

    # tests to ensure it only continues the local for loop and not all of them.
    assigns  = { 'array' => [[1, 2], [3, 4], [5, 6]] }
    markup   = '{% for item in array %}' \
               '{% for i in item %}' \
                 '{% if i == 1 %}' \
                   '{% continue %}' \
                 '{% endif %}' \
                 '{{ i }}' \
               '{% endfor %}' \
             '{% endfor %}'
    expected = '23456'
    assert_template_result(expected, markup, assigns)

    # test continue does nothing when unreached
    assigns  = { 'array' => { 'items' => [1, 2, 3, 4, 5] } }
    markup   = '{% for i in array.items %}{% if i == 9999 %}{% continue %}{% endif %}{{ i }}{% endfor %}'
    expected = '12345'
    assert_template_result(expected, markup, assigns)
  end

  def test_for_tag_string
    # ruby 1.8.7 "String".each => Enumerator with single "String" element.
    # ruby 1.9.3 no longer supports .each on String though we mimic
    # the functionality for backwards compatibility

    assert_template_result(
      'test string',
      '{%for val in string%}{{val}}{%endfor%}',
      { 'string' => "test string" },
    )

    assert_template_result(
      'test string',
      '{%for val in string limit:1%}{{val}}{%endfor%}',
      { 'string' => "test string" },
    )

    assert_template_result(
      'val-string-1-1-0-1-0-true-true-test string',
      '{%for val in string%}' \
      '{{forloop.name}}-' \
      '{{forloop.index}}-' \
      '{{forloop.length}}-' \
      '{{forloop.index0}}-' \
      '{{forloop.rindex}}-' \
      '{{forloop.rindex0}}-' \
      '{{forloop.first}}-' \
      '{{forloop.last}}-' \
      '{{val}}{%endfor%}',
      { 'string' => "test string" },
    )
  end

  def test_for_parentloop_references_parent_loop
    assert_template_result(
      '1.1 1.2 1.3 2.1 2.2 2.3 ',
      '{% for inner in outer %}{% for k in inner %}' \
      '{{ forloop.parentloop.index }}.{{ forloop.index }} ' \
      '{% endfor %}{% endfor %}',
      { 'outer' => [[1, 1, 1], [1, 1, 1]] },
    )
  end

  def test_for_parentloop_nil_when_not_present
    assert_template_result(
      '.1 .2 ',
      '{% for inner in outer %}' \
      '{{ forloop.parentloop.index }}.{{ forloop.index }} ' \
      '{% endfor %}',
      { 'outer' => [[1, 1, 1], [1, 1, 1]] },
    )
  end

  def test_inner_for_over_empty_input
    assert_template_result('oo', '{% for a in (1..2) %}o{% for b in empty %}{% endfor %}{% endfor %}')
  end

  def test_blank_string_not_iterable
    assert_template_result('', "{% for char in characters %}I WILL NOT BE OUTPUT{% endfor %}", { 'characters' => '' })
  end

  def test_bad_variable_naming_in_for_loop
    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse('{% for a/b in x %}{% endfor %}')
    end
  end

  def test_spacing_with_variable_naming_in_for_loop
    expected = '12345'
    template = '{% for       item   in   items %}{{item}}{% endfor %}'
    assigns  = { 'items' => [1, 2, 3, 4, 5] }
    assert_template_result(expected, template, assigns)
  end

  class LoaderDrop < Liquid::Drop
    attr_accessor :each_called, :load_slice_called

    def initialize(data)
      @data = data
    end

    def each
      @each_called = true
      @data.each { |el| yield el }
    end

    def load_slice(from, to)
      @load_slice_called = true
      @data[(from..to - 1)]
    end
  end

  def test_iterate_with_each_when_no_limit_applied
    loader   = LoaderDrop.new([1, 2, 3, 4, 5])
    assigns  = { 'items' => loader }
    expected = '12345'
    template = '{% for item in items %}{{item}}{% endfor %}'
    assert_template_result(expected, template, assigns)
    assert(loader.each_called)
    assert(!loader.load_slice_called)
  end

  def test_iterate_with_load_slice_when_limit_applied
    loader   = LoaderDrop.new([1, 2, 3, 4, 5])
    assigns  = { 'items' => loader }
    expected = '1'
    template = '{% for item in items limit:1 %}{{item}}{% endfor %}'
    assert_template_result(expected, template, assigns)
    assert(!loader.each_called)
    assert(loader.load_slice_called)
  end

  def test_iterate_with_load_slice_when_limit_and_offset_applied
    loader   = LoaderDrop.new([1, 2, 3, 4, 5])
    assigns  = { 'items' => loader }
    expected = '34'
    template = '{% for item in items offset:2 limit:2 %}{{item}}{% endfor %}'
    assert_template_result(expected, template, assigns)
    assert(!loader.each_called)
    assert(loader.load_slice_called)
  end

  def test_iterate_with_load_slice_returns_same_results_as_without
    loader         = LoaderDrop.new([1, 2, 3, 4, 5])
    loader_assigns = { 'items' => loader }
    array_assigns  = { 'items' => [1, 2, 3, 4, 5] }
    expected       = '34'
    template       = '{% for item in items offset:2 limit:2 %}{{item}}{% endfor %}'
    assert_template_result(expected, template, loader_assigns)
    assert_template_result(expected, template, array_assigns)
  end

  def test_for_cleans_up_registers
    context = Context.new(ErrorDrop.new)

    assert_raises(StandardError) do
      Liquid::Template.parse('{% for i in (1..2) %}{{ standard_error }}{% endfor %}').render!(context)
    end

    assert(context.registers[:for_stack].empty?)
  end

  def test_integer_range_is_not_materialized_and_charges_empty_iterations
    range = bounded_integer_range_with_tripwires
    template = Template.parse('{% for i in numbers %}{% endfor %}')
    template.resource_limits.render_score_limit = 3

    assert_raises(Liquid::MemoryError) { template.render!('numbers' => range) }

    assert(template.resource_limits.reached?)
    assert_equal(4, template.resource_limits.render_score)
  end

  def test_integer_range_uses_arithmetic_offsets_reversal_and_metadata
    range = bounded_integer_range_with_tripwires
    template = Template.parse(
      '{% for i in numbers reversed offset:997 limit:2 %}{{ forloop.length }}:{{ i }}{% endfor %}',
    )
    template.resource_limits.render_score_limit = 10

    assert_equal('2:9992:998', template.render!('numbers' => range))
  end

  def test_range_scores_cannot_be_bypassed_by_repeated_renders
    template = Template.parse('{% for i in (1..2) %}{% endfor %}')
    template.resource_limits.cumulative_render_score_limit = 3
    assert_equal('', template.render!)
    assert_raises(Liquid::MemoryError) { template.render! }
  end

  def test_range_break_charges_only_visited_items_and_preserves_full_metadata
    range = bounded_integer_range_with_tripwires
    template = Template.parse(
      '{% for i in numbers reversed %}{{ forloop.length }}:{{ i }}{% break %}{% endfor %}',
    )
    template.resource_limits.render_score_limit = 10

    assert_equal('1000:1000', template.render!('numbers' => range))
    assert_operator(template.resource_limits.render_score, :<=, 10)
  end

  def test_range_subclass_uses_its_custom_each
    range = Class.new(Range) do
      def each
        yield 10
        yield 20
      end
    end.new(nil, 3)

    assert_template_result('1020', '{% for i in numbers %}{{ i }}{% endfor %}', { 'numbers' => range })
  end

  def test_range_subclass_custom_to_a_is_honored_for_finite_and_open_bounds
    range_class = Class.new(Range) do
      def to_a
        [42]
      end
    end

    [range_class.new(1, 3), range_class.new(nil, 3), range_class.new(1, nil)].each do |range|
      assert_template_result('42', '{% for i in numbers %}{{ i }}{% endfor %}', { 'numbers' => range })
    end
  end

  def test_endless_range_remains_unsupported_with_a_limit
    template = Template.parse('{% for i in numbers limit:2 %}{{ i }}{% endfor %}')

    assert_raises(RangeError) { template.render!('numbers' => (1..)) }
  end

  def test_endless_range_subclass_with_custom_each_remains_unsupported
    range = Class.new(Range) do
      def each
        yield 10
        yield 20
      end
    end.new(1, nil)

    assert_raises(RangeError) do
      Template.parse('{% for i in numbers %}{{ i }}{% endfor %}').render!('numbers' => range)
    end
  end

  def test_collection_accepts_grouped_and_ungrouped_logical_expressions
    assigns = { 'fallback' => nil, 'items' => ['a', 'b'] }

    assert_template_result('0=a;1=b;', '{% for item in fallback or items %}{{ forloop.index0 }}={{ item }};{% endfor %}', assigns)
    assert_template_result('0=a;1=b;', '{% for item in (fallback or items) %}{{ forloop.index0 }}={{ item }};{% endfor %}', assigns)
    assert_template_result('ab', '{% for item in items and items %}{{ item }}{% endfor %}', assigns)
    assert_template_result('empty', '{% for item in fallback and items %}{{ item }}{% else %}empty{% endfor %}', assigns)
  end

  def test_collection_expression_returns_the_selected_operand
    assigns = { 'first' => [1, 2], 'second' => [3, 4] }

    assert_template_result('12', '{% for item in first or second %}{{ item }}{% endfor %}', assigns)
    assert_template_result('34', '{% for item in first and second %}{{ item }}{% endfor %}', assigns)
    assert_template_result('12', '{% for item in first or (second and nothing) %}{{ item }}{% endfor %}', assigns)
  end

  def test_collection_expression_with_ranges_and_lookups
    assigns = { 'fallback' => nil, 'collections' => { 'featured' => [7, 8] }, 'key' => 'featured' }

    assert_template_result('123', '{% for item in fallback or (1..3) %}{{ item }}{% endfor %}', assigns)
    assert_template_result('78', '{% for item in fallback or collections[key] %}{{ item }}{% endfor %}', assigns)
    assert_template_result('78', '{% for item in collections[fallback or key] %}{{ item }}{% endfor %}', assigns)
  end

  def test_collection_expression_starting_with_a_lookup
    assigns = {
      'values' => ['a', 'b'],
      'key' => 0,
      'data' => { 'list' => [1, 2], 'missing' => nil, 'keys' => { 'name' => 'list' } },
    }

    assert_template_result('a', '{% for item in values[key] or values %}{{ item }}{% endfor %}', assigns)
    assert_template_result('a', '{% for item in (values[key] or values) %}{{ item }}{% endfor %}', assigns)
    assert_template_result('a', '{% for item in values.first or values %}{{ item }}{% endfor %}', assigns)
    assert_template_result('12', '{% for item in data.list or values %}{{ item }}{% endfor %}', assigns)
    assert_template_result('12', '{% for item in data.missing or data.list %}{{ item }}{% endfor %}', assigns)
    assert_template_result('12', '{% for item in data[data.keys.name] or values %}{{ item }}{% endfor %}', assigns)
    assert_template_result('ab', "{% for item in data[data.keys['name']] and values %}{{ item }}{% endfor %}", assigns)
    assert_template_result('a', '{% for item in data.list and values[key] %}{{ item }}{% endfor %}', assigns)
  end

  def test_collection_expression_starting_with_a_lookup_matches_assign
    assigns = { 'values' => ['a', 'b'], 'key' => 0, 'data' => { 'missing' => nil, 'list' => [1, 2] } }

    [
      'values[key] or values',
      'values.first or values',
      '(data.missing or data.list)',
      "data['missing'] or data.list",
    ].each do |expression|
      workaround = "{% assign selected = #{expression} %}{% for item in selected %}{{ item }},{% endfor %}"
      template = "{% for item in #{expression} %}{{ item }},{% endfor %}"

      assert_equal(Template.parse(workaround).render!(assigns), Template.parse(template).render!(assigns), expression)
    end
  end

  def test_expression_collection_starting_with_a_lookup_keeps_its_loop_name
    assigns = { 'values' => ['a', 'b'], 'key' => 0, 'data' => { 'list' => [1], 'keys' => { 'name' => 'list' } } }

    assert_template_result('item-values[key] or values', '{% for item in values[key] or values %}{{ forloop.name }}{% endfor %}', assigns)
    assert_template_result(
      'item-data[data.keys.name] or values',
      '{% for item in data[data.keys.name] or values %}{{ forloop.name }}{% endfor %}',
      assigns,
    )
  end

  def test_limit_and_offset_expressions_starting_with_a_lookup
    assigns = { 'items' => [1, 2, 3, 4], 'i' => 0, 'counts' => [2, 1], 'settings' => { 'two' => 2, 'one' => 1, 'missing' => nil } }

    assert_template_result('12', '{% for item in items limit: settings.two or 5 %}{{ item }}{% endfor %}', assigns)
    assert_template_result('12', '{% for item in items limit: counts[i] or 5 %}{{ item }}{% endfor %}', assigns)
    assert_template_result('1', '{% for item in items limit: (counts[1] or 3) %}{{ item }}{% endfor %}', assigns)
    assert_template_result('34', '{% for item in items offset: counts[i] or 0 %}{{ item }}{% endfor %}', assigns)
    assert_template_result('234', '{% for item in items offset: settings.missing or counts[1] %}{{ item }}{% endfor %}', assigns)
    assert_template_result(
      '32',
      "{% for item in items reversed limit: counts[i] or 9 offset: settings['missing'] or settings.one %}{{ item }}{% endfor %}",
      assigns,
    )
  end

  def test_limit_and_offset_accept_logical_expressions
    assigns = { 'items' => [1, 2, 3, 4], 'candidate' => nil, 'cap' => 2, 'start' => 1 }

    assert_template_result('12', '{% for item in items limit: candidate or cap %}{{ item }}{% endfor %}', assigns)
    assert_template_result('12', '{% for item in items limit: (candidate or cap) %}{{ item }}{% endfor %}', assigns)
    assert_template_result('234', '{% for item in items offset: candidate or start %}{{ item }}{% endfor %}', assigns)
    assert_template_result('234', '{% for item in items offset: (candidate or start) %}{{ item }}{% endfor %}', assigns)
    assert_template_result('23', '{% for item in items limit: candidate or cap, offset: candidate or start %}{{ item }}{% endfor %}', assigns)
  end

  def test_modifiers_delimit_expressions
    assigns = { 'fallback' => nil, 'items' => [1, 2, 3, 4, 5], 'candidate' => nil, 'cap' => 2, 'skipped' => nil, 'start' => 1 }
    template = '{% for item in fallback or items reversed limit: candidate or cap offset: skipped or start %}{{ item }},{% endfor %}'
    workaround = '{% assign selected = fallback or items %}{% assign count = candidate or cap %}' \
      '{% assign begin = skipped or start %}' \
      '{% for item in selected reversed limit: count offset: begin %}{{ item }},{% endfor %}'

    assert_template_result('3,2,', template, assigns)
    assert_template_result('3,2,', workaround, assigns)
  end

  def test_expression_collection_loop_name_and_continuation
    assigns = { 'fallback' => nil, 'items' => [1, 2, 3, 4] }

    assert_template_result(
      'item-fallback or items|item-(fallback or items)',
      '{% for item in fallback or items limit: 1 %}{{ forloop.name }}{% endfor %}|' \
        '{% for item in (fallback or items) limit: 1 %}{{ forloop.name }}{% endfor %}',
      assigns,
    )
    assert_template_result(
      '12|34',
      '{% for item in fallback or items limit: 2 %}{{ item }}{% endfor %}|' \
        '{% for item in fallback or items offset: continue %}{{ item }}{% endfor %}',
      assigns,
    )
  end

  def test_simple_collections_keep_their_loop_names
    assigns = { 'collections' => { 'featured' => ['a'] }, 'key' => 'featured', 'items' => ['a'] }

    assert_template_result('item-items', '{% for item in items %}{{ forloop.name }}{% endfor %}', assigns)
    assert_template_result('item-(1..1)', '{% for item in ( 1 .. 1 ) %}{{ forloop.name }}{% endfor %}', assigns)
    assert_template_result('item-collections[key]', '{% for item in collections[ key ] %}{{ forloop.name }}{% endfor %}', assigns)
    assert_template_result('item-collections["featured"]', '{% for item in collections["featured"] %}{{ forloop.name }}{% endfor %}', assigns)
  end

  def test_simple_collections_keep_their_previous_lookup_results
    # These lookups render differently through the shared expression grammar.
    # Templates the simple grammar accepted keep their previous output.
    assigns = { 'a' => { ']' => [7, 8], 'x y' => 2 } }

    assert_template_result('empty', '{% for i in a["]"] %}{{ i }}{% else %}empty{% endfor %}', assigns)
    assert_template_result('empty', '{% for i in (a["x y"]..3) %}{{ i }}{% else %}empty{% endfor %}', assigns)
  end

  def test_expression_collection_keeps_resource_limits
    template = Template.parse('{% for i in fallback or numbers %}{% endfor %}')
    template.resource_limits.render_score_limit = 3

    assert_raises(Liquid::MemoryError) { template.render!('numbers' => bounded_integer_range_with_tripwires) }
  end

  def test_invalid_loop_expressions_remain_syntax_errors
    assert_syntax_error('{% for item in fallback or %}{% endfor %}')
    assert_syntax_error('{% for item in (fallback or items %}{% endfor %}')
    assert_syntax_error('{% for item in items limit: candidate or %}{% endfor %}')
    assert_syntax_error('{% for item in items offset: (candidate or) %}{% endfor %}')
    assert_syntax_error('{% for item in fallback or items limit: 1 reversed %}{% endfor %}')
    assert_match_syntax_error(/Invalid attribute in for loop/, '{% for item in fallback or items size: 1 %}{% endfor %}')
  end
end
