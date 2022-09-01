# frozen_string_literal: true

require 'test_helper'

module MoneyFilter
  def money(input)
    format(' %d$ ', input)
  end

  def money_with_underscore(input)
    format(' %d$ ', input)
  end
end

module CanadianMoneyFilter
  def money(input)
    format(' %d$ CAD ', input)
  end
end

module SubstituteFilter
  def substitute(input, params = {})
    input.gsub(/%\{(\w+)\}/) { |_match| params[Regexp.last_match(1)] }
  end
end

class FiltersTest < Minitest::Test
  include Liquid

  module OverrideObjectMethodFilter
    def tap(_input)
      "tap overridden"
    end
  end

  def setup
    @context = Context.new
  end

  def test_local_filter
    @context['var'] = 1000
    @context.add_filters(MoneyFilter)

    assert_equal(' 1000$ ', Template.parse("{{var | money}}").render(@context))
  end

  def test_underscore_in_filter_name
    @context['var'] = 1000
    @context.add_filters(MoneyFilter)
    assert_equal(' 1000$ ', Template.parse("{{var | money_with_underscore}}").render(@context))
  end

  def test_second_filter_overwrites_first
    @context['var'] = 1000
    @context.add_filters(MoneyFilter)
    @context.add_filters(CanadianMoneyFilter)

    assert_equal(' 1000$ CAD ', Template.parse("{{var | money}}").render(@context))
  end

  def test_size
    assert_template_result("4", "{{var | size}}", { "var" => 'abcd' })
  end

  def test_join
    assert_template_result("1 2 3 4", "{{var | join}}", { "var" => [1, 2, 3, 4] })
  end

  def test_sort
    assert_template_result("1 2 3 4", "{{numbers | sort | join}}", { "numbers" => [2, 1, 4, 3] })
    assert_template_result("alphabetic as expected", "{{words | sort | join}}",
      { "words" => ['expected', 'as', 'alphabetic'] })
    assert_template_result("3", "{{value | sort}}", { "value" => 3 })
    assert_template_result('are flower', "{{arrays | sort | join}}", { 'arrays' => ['flower', 'are'] })
    assert_template_result("Expected case sensitive", "{{case_sensitive | sort | join}}",
      { "case_sensitive" => ["sensitive", "Expected", "case"] })
  end

  def test_sort_natural
    # Test strings
    assert_template_result("Assert case Insensitive", "{{words | sort_natural | join}}",
      { "words" => ["case", "Assert", "Insensitive"] })

    # Test hashes
    assert_template_result("A b C", "{{hashes | sort_natural: 'a' | map: 'a' | join}}",
      { "hashes" => [{ "a" => "A" }, { "a" => "b" }, { "a" => "C" }] })

    # Test objects
    @context['objects'] = [TestObject.new('A'), TestObject.new('b'), TestObject.new('C')]
    assert_equal('A b C', Template.parse("{{objects | sort_natural: 'a' | map: 'a' | join}}").render(@context))
  end

  def test_compact
    # Test strings
    assert_template_result("a b c", "{{words | compact | join}}",
      { "words" => ['a', nil, 'b', nil, 'c'] })

    # Test hashes
    assert_template_result("A C", "{{hashes | compact: 'a' | map: 'a' | join}}",
      { "hashes" => [{ "a" => "A" }, { "a" => nil }, { "a" => "C" }] })

    # Test objects
    @context['objects'] = [TestObject.new('A'), TestObject.new(nil), TestObject.new('C')]
    assert_equal('A C', Template.parse("{{objects | compact: 'a' | map: 'a' | join}}").render(@context))
  end

  def test_strip_html
    assert_template_result("bla blub", "{{ var | strip_html }}", { "var" => "<b>bla blub</a>" })
  end

  def test_strip_html_ignore_comments_with_html
    assert_template_result("bla blub", "{{ var | strip_html }}",
      { "var" => "<!-- split and some <ul> tag --><b>bla blub</a>" })
  end

  def test_capitalize
    assert_template_result("Blub", "{{ var | capitalize }}", { "var" => "blub" })
  end

  def test_nonexistent_filter_is_ignored
    assert_template_result("1000", "{{ var | xyzzy }}", { "var" => 1000 })
  end

  def test_filter_with_keyword_arguments
    @context['surname'] = 'john'
    @context['input']   = 'hello %{first_name}, %{last_name}'
    @context.add_filters(SubstituteFilter)
    output              = Template.parse(%({{ input | substitute: first_name: surname, last_name: 'doe' }})).render(@context)
    assert_equal('hello john, doe', output)
  end

  def test_override_object_method_in_filter
    assert_equal("tap overridden", Template.parse("{{var | tap}}").render!({ 'var' => 1000 }, filters: [OverrideObjectMethodFilter]))

    # tap still treated as a non-existent filter
    assert_equal("1000", Template.parse("{{var | tap}}").render!('var' => 1000))
  end

  def test_liquid_argument_error
    source = "{{ '' | size: 'too many args' }}"
    exc = assert_raises(Liquid::ArgumentError) do
      Template.parse(source).render!
    end
    assert_match(/\ALiquid error: wrong number of arguments /, exc.message)
    assert_equal(exc.message, Template.parse(source).render)
  end
end

class FiltersInTemplate < Minitest::Test
  include Liquid

  def test_local_global
    with_global_filter(MoneyFilter) do
      assert_equal(" 1000$ ", Template.parse("{{1000 | money}}").render!(nil, nil))
      assert_equal(" 1000$ CAD ", Template.parse("{{1000 | money}}").render!(nil, filters: CanadianMoneyFilter))
      assert_equal(" 1000$ CAD ", Template.parse("{{1000 | money}}").render!(nil, filters: [CanadianMoneyFilter]))
    end
  end

  def test_local_filter_with_deprecated_syntax
    assert_equal(" 1000$ CAD ", Template.parse("{{1000 | money}}").render!(nil, CanadianMoneyFilter))
    assert_equal(" 1000$ CAD ", Template.parse("{{1000 | money}}").render!(nil, [CanadianMoneyFilter]))
  end
end # FiltersTest

class TestObject < Liquid::Drop
  attr_accessor :a
  def initialize(a)
    @a = a
  end
end
