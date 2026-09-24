# frozen_string_literal: true

require 'test_helper'

class LetClosureTest < Minitest::Test
  def test_value_binding_and_filtered_initializer
    assert_render('HELLO:3', "{% let title = product.title | upcase %}{{ title }}:{% let n = 1 | plus: 2 %}{{ n }}", 'product' => { 'title' => 'hello' })
  end

  def test_initializer_reads_parent_before_installing_shadow
    assert_render('231', '{% let n = 1 %}{% let title(step) %}{% let n = n | plus: step %}{{ n }}{% endlet %}{{ title(1) }}{{ title(2) }}{{ n }}')
  end

  def test_empty_and_parameterless_bodies
    assert_render('ok', '{% let empty %}{% endlet %}{% let title() %}ok{% endlet %}{{ empty() }}{{ title() }}')
  end

  def test_parameters_are_writable_and_fresh
    assert_render('23', '{% let title(n,) %}{% set n = n | plus: 1 %}{{ n }}{% endlet %}{{ title(1,) }}{{ title(2) }}')
  end

  def test_live_captures
    assert_render('12', '{% let n = 1 %}{% let title %}{{ n }}{% endlet %}{{ title() }}{% set n = 2 %}{{ title() }}')
  end

  def test_captured_environments_fall_through_nil_values
    context = Liquid::Context.build(environments: [{ 'n' => nil }, { 'n' => 'fallback' }])
    source = '{{ n }}/{% let show %}{{ n }}{% endlet %}{{ show() }}'
    assert_equal('fallback/fallback', parse(source).render!(context))
  end

  def test_captured_environments_keep_false_values
    context = Liquid::Context.build(environments: [{ 'n' => false }, { 'n' => 'fallback' }])
    source = '{{ n }}/{% let show %}{{ n }}{% endlet %}{{ show() }}'
    assert_equal('false/false', parse(source).render!(context))
  end

  def test_captured_environments_use_hash_defaults
    context = Liquid::Context.build(environments: Hash.new('fallback'))
    source = '{{ n }}/{% let show %}{{ n }}{% endlet %}{{ show() }}'
    assert_equal('fallback/fallback', parse(source).render!(context))
  end

  def test_captured_environments_fall_through_drops
    context = Liquid::Context.build(environments: [Liquid::Drop.new, { 'n' => 'fallback' }])
    source = '{{ n }}/{% let outer %}{% let inner %}{{ n }}{% endlet %}{{ inner() }}{% endlet %}{{ outer() }}'
    assert_equal('fallback/fallback', parse(source).render!(context))
  end

  def test_captured_static_environments_preserve_fallthrough_and_defaults
    context = Liquid::Context.build(environments: [], static_environments: [{ 'n' => nil }, Hash.new('fallback')])
    source = '{{ n }}/{% let show %}{{ n }}{% endlet %}{{ show() }}'
    assert_equal('fallback/fallback', parse(source).render!(context))
  end

  def test_captured_local_nil_shadows_environment_values
    context = Liquid::Context.build(environments: { 'n' => 'dynamic' }, static_environments: { 'n' => 'static' })
    source = '{% let n = nil %}{{ n }}/{% let outer %}{% let inner %}{{ n }}{% endlet %}{{ inner() }}{% endlet %}{{ outer() }}'
    assert_equal('/', parse(source).render!(context))
  end

  def test_captured_local_self_nil_does_not_become_a_self_drop
    source = '{% let self = nil %}{% let show %}{% if self == nil %}nil{% endif %}{% endlet %}{{ show() }}'
    assert_render('nil', source)
  end

  def test_captured_environments_remain_live_and_read_only
    values = { 'n' => 1 }
    source = '{% let show %}{{ n }}{% set n = n | plus: 10 %}{{ n }}{% endlet %}{{ show() }}{% increment n %}{{ show() }}'
    assert_render('1111212', source, values)
    assert_equal(2, values['n'])
  end

  def test_strict_captured_environments_stop_at_nil
    context = Liquid::Context.build(environments: [{ 'n' => nil }, { 'n' => 'fallback' }])
    source = '{{ n }}/{% let show %}{{ n }}{% endlet %}{{ show() }}'
    assert_equal('/', parse(source).render!(context, strict_variables: true))
  end

  def test_strict_captured_environments_reject_missing_keys_before_fallback
    source = '{% let outer %}{% let inner %}{{ n }}{% endlet %}{{ inner() }}{% endlet %}{{ outer() }}'
    context = Liquid::Context.build(environments: [{}, { 'n' => 'fallback' }])
    assert_raises(Liquid::UndefinedVariable) { parse(source).render!(context, strict_variables: true) }
  end

  def test_strict_captured_environments_reject_hash_defaults
    context = Liquid::Context.build(environments: Hash.new('fallback'))
    source = '{% let show %}{{ n }}{% endlet %}{{ show() }}'
    assert_raises(Liquid::UndefinedVariable) { parse(source).render!(context, strict_variables: true) }
  end

  def test_strict_captured_self_lookup_can_fall_back_to_self_drop
    source = '{% let show %}{{ self["n"] }}{% endlet %}{{ show() }}'
    assert_equal('value', parse(source).render!({ 'n' => 'value' }, strict_variables: true))
  end

  def test_render_in_closures_inherits_only_static_globals
    file_system = StubFileSystem.new('snippet' => '{{ g }}/{{ dynamic }}/{{ local }};')
    environment = Liquid::Environment.build(file_system: file_system)
    context = Liquid::Context.build(environment: environment, environments: { 'dynamic' => 'D' }, static_environments: { 'g' => 'G' })
    source = '{% let local = "L" %}{% render "snippet" %}{% let show %}{% render "snippet" %}{% render "snippet", dynamic: dynamic, local: local %}{% endlet %}{{ show() }}'
    assert_equal('G//;G//;G/D/L;', parse(source, environment: environment).render!(context))
  end

  def test_render_in_closures_uses_globals_despite_local_shadows
    file_system = StubFileSystem.new('snippet' => '{{ g }}')
    environment = Liquid::Environment.build(file_system: file_system)
    context = Liquid::Context.build(environment: environment, static_environments: { 'g' => 'G' })
    source = '{% render "snippet" %}/{% let g = nil %}{% let outer %}{% let inner %}{{ g }}{% render "snippet" %}{% endlet %}{{ inner() }}{% endlet %}{{ outer() }}'
    assert_equal('G/G', parse(source, environment: environment).render!(context))
  end

  def test_capture_shadows_are_fresh_and_read_only
    assert_render('221', '{% let n = 1 %}{% let title %}{% set n = n | plus: 1 %}{{ n }}{% endlet %}{{ title() }}{{ title() }}{{ n }}')
  end

  def test_set_creates_missing_binding_at_invocation_root
    source = '{% let title %}{% for i in (1..2) %}{% set n = n | plus: i %}{% endfor %}{{ n }}{% endlet %}{{ title() }}{{ title() }}'
    assert_equal('33', parse(source).render!({}, strict_variables: true))
  end

  def test_set_searches_owned_control_flow_scopes
    source = '{% let title(n) %}{% for i in (1..2) %}{% set n = n | plus: i %}{% set i = i | plus: 10 %}{{ i }},{% endfor %}{{ n }}{% endlet %}{{ title(1) }}'
    assert_render('11,12,4', source)
  end

  def test_set_shadows_capture_at_root_from_inside_loop
    source = '{% let n = 1 %}{% let title %}{% for i in (1..2) %}{% set n = n | plus: i %}{% endfor %}{{ n }}{% endlet %}{{ title() }}{{ n }}'
    assert_render('41', source)
  end

  def test_let_shadows_in_loop_and_can_execute_repeatedly
    source = '{% let n = 10 %}{% for i in (1..3) %}{% let n = i %}{% set n = n | plus: 1 %}{{ n }}{% endfor %}{{ n }}'
    assert_render('23410', source)
  end

  def test_each_iteration_initializer_reads_outer_binding
    source = '{% let n = 10 %}{% for i in (1..2) %}{% let n = n | plus: 1 %}{{ n }},{% endfor %}{{ n }}'
    assert_render('11,11,10', source)
  end

  def test_retained_callbacks_capture_iteration_local_bindings
    source = '{% let n = 10 %}{% let first = nil %}{% let second = nil %}{% for i in (1..2) %}{% let n = n | plus: i %}{% let title %}{{ n }}{% endlet %}{% if i == 1 %}{% set first = title %}{% else %}{% set second = title %}{% endif %}{% endfor %}{{ first() }}/{{ second() }}:{{ n }}'
    assert_render('11/12:10', source)
  end

  def test_set_traverses_fresh_iteration_frames_and_persists_at_root
    source = '{% let captured = 5 %}{% let title(n) %}{% for i in (1..2) %}{% let step = i %}{% set n = n | plus: step %}{% set missing = missing | plus: step %}{% set captured = captured | plus: step %}{% endfor %}{{ n }}/{{ missing }}/{{ captured }};{% endlet %}{{ title(1) }}{{ title(1) }}{{ captured }}'
    assert_equal('4/3/8;4/3/8;5', parse(source).render!({}, strict_variables: true))
  end

  def test_each_table_row_initializer_reads_outer_binding
    source = '{% let n = 10 %}{% tablerow i in (1..2) %}{% let n = n | plus: 1 %}{{ n }}{% endtablerow %}{{ n }}'
    assert_render("<tr class=\"row1\">\n<td class=\"col1\">11</td><td class=\"col2\">11</td></tr>\n10", source)
  end

  def test_table_row_callbacks_retain_iteration_local_bindings
    source = '{% let first = nil %}{% let second = nil %}{% tablerow i in (1..2) %}{% let n = i %}{% let title %}{{ n }}{% endlet %}{% if i == 1 %}{% set first = title %}{% else %}{% set second = title %}{% endif %}{% endtablerow %}{{ first() }}/{{ second() }}'
    assert_render("<tr class=\"row1\">\n<td class=\"col1\"></td><td class=\"col2\"></td></tr>\n1/2", source)
  end

  def test_set_traverses_table_row_frames_to_invocation_root
    source = '{% let title(n) %}{% tablerow i in (1..2) %}{% let step = i %}{% set n = n | plus: step %}{% set missing = missing | plus: step %}{% endtablerow %}{{ n }}/{{ missing }}{% endlet %}{{ title(1) }}'
    assert_render("<tr class=\"row1\">\n<td class=\"col1\"></td><td class=\"col2\"></td></tr>\n4/3", source)
  end

  def test_empty_loop_branch_has_its_own_let_scope
    source = '{% let n = 1 %}{% for i in missing %}{% else %}{% let n = 2 %}{{ n }}{% endfor %}{{ n }}'
    assert_render('21', source)
  end

  def test_table_row_scope_can_shadow_outer_let
    source = '{% let n = 10 %}{% tablerow i in (1..2) %}{% let n = i %}{{ n }}{% endtablerow %}{{ n }}'
    assert_render("<tr class=\"row1\">\n<td class=\"col1\">1</td><td class=\"col2\">2</td></tr>\n10", source)
  end

  def test_body_declaration_can_execute_on_every_iteration
    assert_render('123', '{% for i in (1..3) %}{% let title %}{{ i }}{% endlet %}{{ title() }}{% endfor %}')
  end

  def test_set_updates_nearest_owned_let
    source = '{% let title(n) %}{% for i in (1..2) %}{% let n = i %}{% set n = n | plus: 10 %}{{ n }},{% endfor %}{{ n }}{% endlet %}{{ title(5) }}'
    assert_render('11,12,5', source)
  end

  def test_nested_closures_have_live_read_only_captures
    source = '{% let outer(n) %}{% let inner %}{% set n = n | plus: 10 %}{{ n }}{% endlet %}{% set n = n | plus: 1 %}{{ inner() }}{{ n }}{% endlet %}{{ outer(1) }}{{ outer(2) }}'
    assert_render('122133', source)
  end

  def test_captures_search_all_parents_with_strict_variables
    source = '{% let outer %}{% let inner %}{{ title }}{% endlet %}{{ inner() }}{% endlet %}{{ outer() }}'
    assert_equal('hello', parse(source).render!({ 'title' => 'hello' }, strict_variables: true))
  end

  def test_repeated_renders_start_with_fresh_bindings
    template = parse('{% set n = n | plus: 1 %}{% let title %}{% set n = n | plus: 1 %}{{ n }}{% endlet %}{{ title() }}{{ n }}')
    2.times { assert_equal('21', template.render!) }
  end

  def test_repeated_renders_use_current_inputs
    template = parse('{% let title = title | upcase %}{% let render_title %}{{ title }}{% endlet %}{{ render_title() }}')
    assert_equal('FIRST', template.render!('title' => 'first'))
    assert_equal('SECOND', template.render!('title' => 'second'))
  end

  def test_nil_and_false_bindings_are_owned
    source = '{% let title %}{% let n = nil %}{% set n = n | default: 3 %}{% let flag = false %}{% set flag = true %}{{ n }}{{ flag }}{% endlet %}{{ title() }}'
    assert_render('3true', source)
  end

  def test_nested_call_arguments_and_filters
    source = '{% let title(text) %}[{{ text }}]{% endlet %}{{ title(title("hello")) | upcase }}'
    assert_render('[[HELLO]]', source)
  end

  def test_calls_in_filter_arguments_conditions_and_dynamic_lookups
    source = '{% let key %}title{% endlet %}{% if key() == "title" %}{{ product[key()] | append: key() }}{% endif %}'
    assert_render('hellotitle', source, 'product' => { 'title' => 'hello' })
  end

  def test_calls_in_ranges
    assert_render('123', '{% let finish %}3{% endlet %}{% for i in (1..finish()) %}{{ i }}{% endfor %}')
  end

  def test_callable_ranges_share_loop_continuation
    source = '{% let finish %}3{% endlet %}{% for i in (1..finish()) limit: 1 %}{{ i }}{% endfor %}{% for i in ( 1 .. finish( ) ) limit: 1 offset: continue %}{{ i }}{% endfor %}'
    assert_render('12', source)
  end

  def test_callable_dynamic_lookups_share_loop_continuation
    source = '{% let key %}items{% endlet %}{% for i in groups[key()] limit: 1 %}{{ i }}{% endfor %}{% for i in groups[ key( ) ] limit: 1 offset: continue %}{{ i }}{% endfor %}'
    assert_render('12', source, 'groups' => { 'items' => [1, 2, 3] })
  end

  def test_callable_collection_loop_names_preserve_syntax
    source = '{% let identity(value) %}{{ value }}{% endlet %}{% let key %}items{% endlet %}{% for i in identity("a b") %}{{ forloop.name }}{% endfor %}/{% for i in groups[key()] limit: 1 %}{{ forloop.name }}{% endfor %}/{% for i in (1..identity(3)) limit: 1 %}{{ forloop.name }}{% endfor %}'
    assert_render('i-identity("a b")/i-groups[key()]/i-(1..identity(3))', source, 'groups' => { 'items' => [1, 2, 3] })
  end

  def test_distinct_callable_arguments_have_separate_loop_continuations
    source = '{% let finish(value) %}{{ value }}{% endlet %}{% for i in (1..finish(2)) limit: 1 %}{{ i }}{% endfor %}{% for i in (1..finish(3)) limit: 1 offset: continue %}{{ i }}{% endfor %}'
    assert_render('11', source)
  end

  def test_callable_value_can_be_passed_through_let
    assert_render('hello', '{% let title %}hello{% endlet %}{% let alias = title %}{{ alias() }}')
  end

  def test_multiline_liquid
    source = <<~LIQUID
      {% liquid
        let n = 1
        let title(step)
          set n = n | plus: step
          echo n
        endlet
        echo title(2)
        echo n
      %}
    LIQUID
    assert_render("31\n", source)
  end

  def test_same_scope_redeclarations_are_parse_errors
    [
      '{% let n = 1 %}{% let n = 2 %}',
      '{% let n %}{% endlet %}{% let n = 2 %}',
      '{% let title(n) %}{% let n = 1 %}{% endlet %}',
      '{% let title %}{% let n = 1 %}{% if false %}{% let n = 2 %}{% endif %}{% endlet %}',
    ].each do |source|
      assert_raises(Liquid::SyntaxError, source) { parse(source) }
    end
  end

  def test_invalid_headers_and_complete_input_validation
    [
      '{% let %}',
      '{% let 1 = 2 %}',
      '{% let a.b = 2 %}',
      '{% let a == 2 %}',
      '{% let a = %}',
      '{% let a = 1 junk %}',
      '{% let a = 1 | %}',
      '{% let a(x) = 2 %}',
      '{% let a(x,x) %}{% endlet %}',
      '{% let a(,x) %}{% endlet %}',
      '{% let a(x,,) %}{% endlet %}',
      '{% let a(x) junk %}{% endlet %}',
      '{% let a %}',
      '{% set %}',
      '{% set a.b = 1 %}',
      '{% set a == 1 %}',
      '{% set a = %}',
      '{% set a = 1 junk %}',
      '{{ title(,1) }}',
      '{{ title(1,,) }}',
      '{{ title(1) junk }}',
      '{{ title(1 }}',
    ].each do |source|
      assert_raises(Liquid::SyntaxError, source) { parse(source) }
    end
  end

  def test_assign_is_rejected_through_nested_control_flow
    [
      '{% assign x = 1 %}',
      '{% if false %}{% assign x = 1 %}{% endif %}',
      '{% for i in (1..2) %}{% unless false %}{% assign x = 1 %}{% endunless %}{% endfor %}',
      '{% case n %}{% when 1 %}{% assign x = 1 %}{% endcase %}',
      "{% liquid\nif false\nassign x = 1\nendif\n%}",
    ].each do |body|
      error = assert_raises(Liquid::SyntaxError) { parse("{% let title %}#{body}{% endlet %}") }
      assert_match('assign is not allowed', error.message)
    end
  end

  def test_assign_still_works_outside_closures
    assert_render('12', '{% assign n = 1 %}{% let title %}{{ n }}{% endlet %}{{ title() }}{% assign n = 2 %}{{ title() }}')
  end

  def test_capture_tag_does_not_mutate_parent_bindings
    assert_render('localparent', '{% let n = "parent" %}{% let title %}{% capture n %}local{% endcapture %}{{ n }}{% endlet %}{{ title() }}{{ n }}')
  end

  def test_counters_in_closures_have_fresh_shadows
    source = '{% let n = 5 %}{% let title %}{% increment n %}{{ n }}{% decrement n %}{{ n }}{% endlet %}{{ title() }}{{ title() }}{{ n }}'
    assert_render('565556555', source)
  end

  def test_tags_are_unavailable_in_every_other_mode
    [:lax, :warn, :strict, :rigid].each do |mode|
      ['{% let n = 1 %}', '{% let title %}{% endlet %}', '{% set n = 1 %}'].each do |source|
        assert_raises(Liquid::SyntaxError, "#{mode}: #{source}") { Liquid::Template.parse(source, error_mode: mode) }
      end
    end
  end

  def test_calls_preserve_legacy_parsing_behavior
    [:lax, :warn].each do |mode|
      template = Liquid::Template.parse('{{ title(1) }}', error_mode: mode)
      assert_equal('', template.render!('title' => 'value'))
    end
    [:strict, :rigid].each do |mode|
      assert_raises(Liquid::SyntaxError) { Liquid::Template.parse('{{ title(1) }}', error_mode: mode) }
    end
  end

  def test_effective_template_mode_overrides_environment
    environment = Liquid::Environment.build(error_mode: :strict)
    assert_equal('1', parse('{% let n = 1 %}{{ n }}', environment: environment).render!)
    environment = Liquid::Environment.build(error_mode: :strict2)
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse('{% let n = 1 %}', environment: environment, error_mode: :strict) }
  end

  def test_effective_partial_mode_enables_feature
    environment = Liquid::Environment.build(error_mode: :strict2, file_system: StubFileSystem.new('snippet' => '{% let title %}ok{% endlet %}{{ title() }}'))
    template = Liquid::Template.parse('{% render "snippet" %}', environment: environment, error_mode: :strict, include_options_blacklist: [:error_mode])
    assert_equal('ok', template.render!)
  end

  def test_effective_partial_mode_disables_feature
    [:lax, :warn, :strict, :rigid].each do |mode|
      environment = Liquid::Environment.build(error_mode: mode, file_system: StubFileSystem.new('snippet' => '{% let n = 1 %}'))
      template = parse('{% render "snippet" %}', environment: environment, include_options_blacklist: [:error_mode])
      assert_raises(Liquid::SyntaxError) { template.render! }
    end
  end

  def test_callable_security
    callable = Object.new
    def callable.to_liquid
      self
    end

    def callable.call(*)
      raise 'must not call arbitrary Ruby objects'
    end
    [callable, Liquid::Drop.new, 'text', 1, nil].each do |value|
      assert_raises(Liquid::ArgumentError) { parse('{{ title(1) }}').render!('title' => value) }
    end
  end

  def test_proc_lookup_is_unchanged_and_receives_no_callable_arguments
    values = { 'title' => -> { 'resolved' } }
    template = parse('{{ title(1) }}')
    assert_raises(Liquid::ArgumentError) { template.render!(values) }
    assert_equal('resolved', values['title'])
    assert_equal('resolved', parse('{{ title }}').render!(values))
  end

  def test_proc_captures_keep_existing_lookup_and_memoization
    values = { 'title' => -> { 'resolved' } }
    assert_render('resolvedresolved', '{% let show %}{{ title }}{% endlet %}{{ show() }}{{ show() }}', values)
    assert_equal('resolved', values['title'])
  end

  def test_nil_proc_captures_are_memoized_before_environment_fallback
    values = { 'n' => -> { nil } }
    context = Liquid::Context.build(environments: [values, { 'n' => 'fallback' }])
    source = '{% let show %}{{ n }}{% endlet %}{{ show() }}/{{ show() }}'
    assert_equal('fallback/fallback', parse(source).render!(context))
    assert_nil(values['n'])
  end

  def test_nested_proc_captures_receive_the_current_invocation_context
    values = { 'n' => ->(context) { context['argument'] } }
    source = '{% let outer %}{% let inner(argument) %}{{ n }}{% endlet %}{{ inner("value") }}{% endlet %}{{ outer() }}'
    assert_render('value', source, values)
    assert_equal('value', values['n'])
  end

  def test_argument_count_is_validated
    ['title()', 'title(1,2)'].each do |call|
      assert_raises(Liquid::ArgumentError) { parse("{% let title(n) %}{{ n }}{% endlet %}{{ #{call} }}").render! }
    end
  end

  def test_recursion_uses_liquid_runtime_depth_limit
    template = parse('{% let title %}{{ title() }}{% endlet %}{{ title() }}')
    assert_raises(Liquid::StackLevelError) { template.render! }
  end

  def test_output_buffer_and_output_limit
    template = parse('{% let title %}hello{% endlet %}{{ title() }}{{ title() }}')
    output = +'prefix:'
    assert_same(output, template.render!({}, output: output))
    assert_equal('prefix:hellohello', output)
    template.resource_limits.render_length_limit = 9
    assert_raises(Liquid::MemoryError) { template.render! }
  end

  def test_assignment_limits_include_let_set_and_callable_initializers
    ['{% let n = "hello" %}', '{% set n = "hello" %}', '{% let title %}hello{% endlet %}{% let n = title() %}'].each do |source|
      template = parse(source)
      template.resource_limits.assign_score_limit = 4
      assert_raises(Liquid::MemoryError) { template.render! }
    end
  end

  def test_render_score_limit_includes_callable_body
    template = parse('{% let title %}hello{% endlet %}{{ title() }}{{ title() }}')
    template.resource_limits.render_score_limit = 4
    assert_raises(Liquid::MemoryError) { template.render! }
  end

  def test_visitor_sees_initializers_arguments_and_bodies_without_captures
    template = parse('{% let n = source | plus: step %}{% let title(x) %}{% set n = other %}{{ x }}{% endlet %}{{ title(product.name) }}')
    visitor = Liquid::ParseTreeVisitor.for(template.root).add_callback_for(Liquid::VariableLookup) { |node| node.name } # rubocop:disable Style/SymbolProc
    expected = ['source', 'step', 'other', 'x', 'title', 'product']
    assert_equal(expected, visitor.visit.flatten.compact)
    template.render!('source' => 1, 'step' => 2, 'other' => 3, 'product' => { 'name' => 'hello' })
    assert_equal(expected, visitor.visit.flatten.compact)
  end

  def test_visitor_includes_initializer_filter_keyword_arguments
    template = parse('{% let n = source | default: fallback, allow_false: flag %}')
    visitor = Liquid::ParseTreeVisitor.for(template.root).add_callback_for(Liquid::VariableLookup) { |node| node.name } # rubocop:disable Style/SymbolProc
    assert_equal(['source', 'fallback', 'flag'], visitor.visit.flatten.compact)
  end

  def test_custom_closure_body_parameters_are_writable_and_fresh
    with_custom_tag('parameterized', ParameterizedBody) do
      source = '{% let value = 10 %}{% parameterized %}{% set value = value | plus: 1 %}{{ value }}{% endparameterized %}{{ value }}'
      assert_render('2310', source)
    end
  end

  def test_custom_closure_body_exports_only_direct_child_body_declarations
    source = '{% let n = 1 %}{% compose %}{% set n = n | plus: 1 %}{% let value = "hidden" %}{% if true %}{% let nested %}hidden{% endlet %}{% endif %}{% let item(text) %}{{ n }}:{{ text }}{% endlet %}{% endcompose %}{{ n }}'
    with_custom_tag('compose', Compose) do
      template = parse(source)
      assert_equal('2:a|2:a|1', template.render!)
      assert_equal('2:a|2:a|1', template.render!)
    end
  end

  def test_custom_closure_bodies_can_nest
    source = '{% compose %}{% let item(text) %}{% compose %}{% let item(inner) %}{{ text }}{{ inner }}{% endlet %}{% endcompose %}{% endlet %}{% endcompose %}'
    with_custom_tag('compose', Compose) { assert_render('aa|aa||aa|aa||', source) }
  end

  def test_multiline_liquid_declarations_are_direct_child_exports
    source = "{% compose %}{% liquid\nlet item(text)\necho text\nendlet\n%}{% endcompose %}"
    with_custom_tag('compose', Compose) { assert_render('a|a|', source) }
  end

  def test_custom_closure_body_api_requires_strict2
    with_custom_tag('compose', Compose) do
      [:lax, :warn, :strict, :rigid].each do |mode|
        assert_raises(Liquid::SyntaxError) { Liquid::Template.parse('{% compose %}{% endcompose %}', error_mode: mode) }
      end
    end
  end

  def test_custom_closure_body_rejects_nested_assign
    with_custom_tag('compose', Compose) do
      assert_raises(Liquid::SyntaxError) { parse('{% compose %}{% if false %}{% assign n = 1 %}{% endif %}{% endcompose %}') }
    end
  end

  private

  def parse(source, **options)
    Liquid::Template.parse(source, **options, error_mode: :strict2)
  end

  def assert_render(expected, source, values = {})
    assert_equal(expected, parse(source).render!(values))
  end

  class ParameterizedBody < Liquid::Block
    def parse(tokens)
      @closure_body = parse_closure_body(tokens, parameters: ['value'])
    end

    def render_to_output_buffer(context, output)
      body = @closure_body.bind(context)
      body.render_to_output_buffer(context, output, [1])
      body.render_to_output_buffer(context, output, [2])
    end
  end

  class Compose < Liquid::Block
    def initialize(tag_name, markup, parse_context)
      super
      @component = Liquid::Template.parse("{{ item('a') }}|", environment: parse_context.environment, error_mode: :strict2)
    end

    def parse(tokens)
      @closure_body = parse_closure_body(tokens)
    end

    def render_to_output_buffer(context, output)
      body = @closure_body.bind(context)
      2.times do
        exports = body.invoke(context, output: output)
        raise Liquid::ArgumentError, 'Unexpected exports' unless exports.keys == ['item']

        inner = context.new_isolated_subcontext
        inner.merge(exports)
        @component.root.render_to_output_buffer(inner, output)
      end
      output
    end
  end
end
