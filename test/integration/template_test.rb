# frozen_string_literal: true

require 'test_helper'
require 'timeout'

class TemplateContextDrop < Liquid::Drop
  def liquid_method_missing(method)
    method
  end

  def foo
    'fizzbuzz'
  end

  def baz
    @context.registers['lulz']
  end
end

class SomethingWithLength < Liquid::Drop
  def length
    nil
  end
end

class ErroneousDrop < Liquid::Drop
  def bad_method
    raise 'ruby error in drop'
  end
end

class DropWithUndefinedMethod < Liquid::Drop
  def foo
    'foo'
  end
end

class TemplateTest < Minitest::Test
  include Liquid

  def test_warnings_is_not_exponential_time
    str = "false"
    100.times do
      str = "{% if true %}true{% else %}#{str}{% endif %}"
    end

    t = Template.parse(str)
    assert_equal([], Timeout.timeout(1) { t.warnings })
  end

  def test_custom_assigns_do_not_persist_on_same_template
    t = Template.new
    assert_equal('from custom assigns', t.parse("{{ foo }}").render!('foo' => 'from custom assigns'))
    assert_equal('', t.parse("{{ foo }}").render!)
  end

  def test_custom_assigns_squash_instance_assigns
    t = Template.new
    assert_equal('from instance assigns', t.parse("{% assign foo = 'from instance assigns' %}{{ foo }}").render!)
    assert_equal('from custom assigns', t.parse("{{ foo }}").render!('foo' => 'from custom assigns'))
  end

  def test_lambda_is_called_once_from_custom_assigns_over_multiple_parses_and_renders
    t = Template.new
    assigns = { 'number' => -> {
                              @global ||= 0
                              @global  += 1
                            } }
    assert_equal('1', t.parse("{{number}}").render!(assigns))
    assert_equal('1', t.parse("{{number}}").render!(assigns))
    assert_equal('1', t.render!(assigns))
    @global = nil
  end

  def test_resource_limits_works_with_custom_length_method
    t = Template.parse("{% assign foo = bar %}")
    context = Liquid::Context.new("bar" => SomethingWithLength.new)
    context.resource_limits.render_length_limit = 42
    assert_equal("", t.render!(context))
  end

  def test_resource_limits_render_length
    t = Template.parse("0123456789")
    context = Liquid::Context.new
    context.resource_limits.render_length_limit = 5
    assert_equal("Liquid error: Memory limits exceeded", t.render(context))
    assert(context.resource_limits.reached?)

    context.resource_limits.render_length_limit = 10
    assert_equal("0123456789", t.render!)
    refute_nil(context.resource_limits.render_length)
  end

  def test_resource_limits_render_score
    t = Template.parse("{% for a in (1..10) %} {% for a in (1..10) %} foo {% endfor %} {% endfor %}")
    context = Liquid::Context.new
    context.resource_limits.render_score_limit = 50
    assert_equal("Liquid error: Memory limits exceeded", t.render(context))
    assert(context.resource_limits.reached?)

    t = Template.parse("{% for a in (1..100) %} foo {% endfor %}")
    context.resource_limits.render_score_limit = 50
    assert_equal("Liquid error: Memory limits exceeded", t.render(context))
    assert(context.resource_limits.reached?)

    context.resource_limits.render_score_limit = 200
    assert_equal((" foo " * 100), t.render!(context))
    refute_nil(context.resource_limits.render_score)
  end

  def test_resource_limits_assign_score
    t = Template.parse("{% assign foo = 42 %}{% assign bar = 23 %}")
    context = Liquid::Context.new
    context.resource_limits.assign_score_limit = 1
    assert_equal("Liquid error: Memory limits exceeded", t.render(context))
    assert(context.resource_limits.reached?)

    context.resource_limits.assign_score_limit = 2
    assert_equal("", t.render!(context))
    refute_nil(context.resource_limits.assign_score)
  end

  def test_resource_limits_assign_score_counts_bytes_not_characters
    t = Template.parse("{% assign foo = 'すごい' %}")
    context = Liquid::Context.new
    t.render(context)
    assert_equal(9, context.resource_limits.assign_score)

    t = Template.parse("{% capture foo %}すごい{% endcapture %}")
    t.render(context)
    assert_equal(9, context.resource_limits.assign_score)
  end

  def test_resource_limits_assign_score_nested
    t = Template.parse("{% assign foo = 'aaaa' | reverse %}")

    context = Liquid::Context.new
    context.resource_limits.assign_score_limit = 3
    assert_equal("Liquid error: Memory limits exceeded", t.render(context))
    assert(context.resource_limits.reached?)

    context.resource_limits.assign_score_limit = 5
    assert_equal("", t.render!(context))
  end

  def test_resource_limits_aborts_rendering_after_first_error
    t = Template.parse("{% for a in (1..100) %} foo1 {% endfor %} bar {% for a in (1..100) %} foo2 {% endfor %}")
    context = Liquid::Context.new
    context.resource_limits.render_score_limit = 50
    assert_equal("Liquid error: Memory limits exceeded", t.render(context))
    assert(context.resource_limits.reached?)
  end

  def test_resource_limits_hash_in_template_gets_updated_even_if_no_limits_are_set
    t = Template.parse("{% for a in (1..100) %} {% assign foo = 1 %} {% endfor %}")
    context = Liquid::Context.new
    t.render!(context)
    assert(context.resource_limits.assign_score > 0)
    assert(context.resource_limits.render_score > 0)
    assert(context.resource_limits.render_length > 0)
  end

  def test_render_length_persists_between_blocks
    t = Template.parse("{% if true %}aaaa{% endif %}")
    context = Liquid::Context.new
    context.resource_limits.render_length_limit = 7
    assert_equal("Liquid error: Memory limits exceeded", t.render(context))
    context.resource_limits.render_length_limit = 8
    assert_equal("aaaa", t.render(context))

    t = Template.parse("{% if true %}aaaa{% endif %}{% if true %}bbb{% endif %}")
    context = Liquid::Context.new
    context.resource_limits.render_length_limit = 13
    assert_equal("Liquid error: Memory limits exceeded", t.render(context))
    context.resource_limits.render_length_limit = 14
    assert_equal("aaaabbb", t.render(context))

    t = Template.parse("{% if true %}a{% endif %}{% if true %}b{% endif %}{% if true %}a{% endif %}{% if true %}b{% endif %}{% if true %}a{% endif %}{% if true %}b{% endif %}")
    context = Liquid::Context.new
    context.resource_limits.render_length_limit = 5
    assert_equal("Liquid error: Memory limits exceeded", t.render(context))
    context.resource_limits.render_length_limit = 11
    assert_equal("Liquid error: Memory limits exceeded", t.render(context))
    context.resource_limits.render_length_limit = 12
    assert_equal("ababab", t.render(context))
  end

  def test_render_length_uses_number_of_bytes_not_characters
    t = Template.parse("{% if true %}すごい{% endif %}")
    context = Liquid::Context.new
    context.resource_limits.render_length_limit = 10
    assert_equal("Liquid error: Memory limits exceeded", t.render(context))
    context.resource_limits.render_length_limit = 18
    assert_equal("すごい", t.render(context))
  end

  def test_default_resource_limits_unaffected_by_render_with_context
    context = Context.new
    t = Template.parse("{% for a in (1..100) %} {% assign foo = 1 %} {% endfor %}")
    t.render!(context)
    assert(context.resource_limits.assign_score > 0)
    assert(context.resource_limits.render_score > 0)
    assert(context.resource_limits.render_length > 0)
  end

  def test_can_use_drop_as_context
    t = Template.new
    drop = TemplateContextDrop.new
    context = Liquid::Context.build(environments: drop, registers: { 'lulz' => 'haha' })
    drop.context = context
    assert_equal('fizzbuzz', t.parse('{{foo}}').render!(context))
    assert_equal('bar', t.parse('{{bar}}').render!(context))
    assert_equal('haha', t.parse("{{baz}}").render!(context))
  end

  def test_render_bang_force_rethrow_errors_on_passed_context
    context = Context.new('drop' => ErroneousDrop.new)
    t = Template.new.parse('{{ drop.bad_method }}')

    e = assert_raises RuntimeError do
      t.render!(context)
    end
    assert_equal('ruby error in drop', e.message)
  end

  def test_exception_renderer_that_returns_string
    exception = nil
    handler   = ->(e) {
      exception = e
      '<!-- error -->'
    }

    output = Template.parse("{{ 1 | divided_by: 0 }}").render({}, exception_renderer: handler)

    assert(exception.is_a?(Liquid::ZeroDivisionError))
    assert_equal('<!-- error -->', output)
  end

  def test_exception_renderer_that_raises
    exception = nil
    assert_raises(Liquid::ZeroDivisionError) do
      Template.parse("{{ 1 | divided_by: 0 }}").render({}, exception_renderer: ->(e) {
                                                                                 exception = e
                                                                                 raise
                                                                               })
    end
    assert(exception.is_a?(Liquid::ZeroDivisionError))
  end

  def test_global_filter_option_on_render
    global_filter_proc = ->(output) { "#{output} filtered" }
    rendered_template  = Template.parse("{{name}}").render({ "name" => "bob" }, global_filter: global_filter_proc)

    assert_equal('bob filtered', rendered_template)
  end

  def test_global_filter_option_when_native_filters_exist
    global_filter_proc = ->(output) { "#{output} filtered" }
    rendered_template  = Template.parse("{{name | upcase}}").render({ "name" => "bob" }, global_filter: global_filter_proc)

    assert_equal('BOB filtered', rendered_template)
  end

  def test_undefined_variables
    t = Template.parse("{{x}} {{y}} {{z.a}} {{z.b}} {{z.c.d}}")
    context = Liquid::Context.new('x' => 33, 'z' => { 'a' => 32, 'c' => { 'e' => 31 } })
    result = t.render(context, strict_variables: true)

    assert_equal('33  32  ', result)
    assert_equal(3, context.errors.count)
    assert_instance_of(Liquid::UndefinedVariable, context.errors[0])
    assert_equal('Liquid error: undefined variable y', context.errors[0].message)
    assert_instance_of(Liquid::UndefinedVariable, context.errors[1])
    assert_equal('Liquid error: undefined variable b', context.errors[1].message)
    assert_instance_of(Liquid::UndefinedVariable, context.errors[2])
    assert_equal('Liquid error: undefined variable d', context.errors[2].message)
  end

  def test_nil_value_does_not_raise
    Liquid::Template.error_mode = :strict
    t = Template.parse("some{{x}}thing")
    context = Liquid::Context.new('x' => nil)
    result = t.render!(context, strict_variables: true)

    assert_equal(0, context.errors.count)
    assert_equal('something', result)
  end

  def test_undefined_variables_raise
    t = Template.parse("{{x}} {{y}} {{z.a}} {{z.b}} {{z.c.d}}")

    assert_raises UndefinedVariable do
      t.render!({ 'x' => 33, 'z' => { 'a' => 32, 'c' => { 'e' => 31 } } }, strict_variables: true)
    end
  end

  def test_undefined_drop_methods
    d = DropWithUndefinedMethod.new
    t = Template.new.parse('{{ foo }} {{ woot }}')
    context = Liquid::Context.new(d)
    d.context = context
    result = t.render(context, strict_variables: true)

    assert_equal('foo ', result)
    assert_equal(1, context.errors.count)
    assert_instance_of(Liquid::UndefinedDropMethod, context.errors[0])
  end

  def test_undefined_drop_methods_raise
    d = DropWithUndefinedMethod.new
    t = Template.new.parse('{{ foo }} {{ woot }}')

    assert_raises UndefinedDropMethod do
      t.render!(d, strict_variables: true)
    end
  end

  def test_undefined_filters
    t = Template.parse("{{a}} {{x | upcase | somefilter1 | somefilter2 | somefilter3}}")
    filters = Module.new do
      def somefilter3(v)
        "-#{v}-"
      end
    end
    context = Liquid::Context.new('a' => 123, 'x' => 'foo')
    result = t.render(context, filters: [filters], strict_filters: true)

    assert_equal('123 ', result)
    assert_equal(1, context.errors.count)
    assert_instance_of(Liquid::UndefinedFilter, context.errors[0])
    assert_equal('Liquid error: undefined filter somefilter1', context.errors[0].message)
  end

  def test_undefined_filters_raise
    t = Template.parse("{{x | somefilter1 | upcase | somefilter2}}")

    assert_raises UndefinedFilter do
      t.render!({ 'x' => 'foo' }, strict_filters: true)
    end
  end

  def test_using_range_literal_works_as_expected
    t = Template.parse("{% assign foo = (x..y) %}{{ foo }}")
    result = t.render('x' => 1, 'y' => 5)
    assert_equal('1..5', result)

    t = Template.parse("{% assign nums = (x..y) %}{% for num in nums %}{{ num }}{% endfor %}")
    result = t.render('x' => 1, 'y' => 5)
    assert_equal('12345', result)
  end

  def test_render_uses_correct_disabled_tags_instance
    Liquid::Template.file_system = StubFileSystem.new(
      'foo' => 'bar',
      'test_include' => '{% include "foo" %}'
    )

    disabled_tags = DisabledTags.new
    context = Context.build(registers: { disabled_tags: disabled_tags })

    source = "{% render 'test_include' %}"
    parse_context = Liquid::ParseContext.new(line_numbers: true, error_mode: :strict)
    document = Document.parse(Liquid::Tokenizer.new(source, true), parse_context)

    assert_equal("include usage is not allowed in this context", document.render(context))
  end

  def test_render_sets_context_static_register_when_register_key_does_exist
    disabled_tags_for_test = DisabledTags.new
    Template.add_register(:disabled_tags, disabled_tags_for_test)

    t = Template.parse("{% if true %} Test Template {% endif %}")

    context = Context.new
    refute(context.registers.key?(:disabled_tags))

    t.render(context)

    assert(context.registers.key?(:disabled_tags))
    assert_equal(disabled_tags_for_test, context.registers[:disabled_tags])
  end

  def test_render_does_not_override_context_static_register_when_register_key_exists
    context = Context.new
    context.registers[:random_register] = nil
    Template.add_register(:random_register, {})

    t = Template.parse("{% if true %} Test Template {% endif %}")

    t.render(context)

    assert_nil(context.registers[:random_register])
    assert(context.registers.key?(:random_register))
  end
end
