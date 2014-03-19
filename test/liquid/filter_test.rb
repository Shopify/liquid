require 'test_helper'

module MoneyFilter
  def money(input)
    sprintf(' %d$ ', input)
  end

  def money_with_underscore(input)
    sprintf(' %d$ ', input)
  end
end

module CanadianMoneyFilter
  def money(input)
    sprintf(' %d$ CAD ', input)
  end
end

module SubstituteFilter
  def substitute(input, params={})
    input.gsub(/%\{(\w+)\}/) { |match| params[$1] }
  end
end

class FiltersTest < Test::Unit::TestCase
  include Liquid

  def setup
    @context = Context.new
  end

  def test_local_filter
    @context['var'] = 1000
    @context.add_filters(MoneyFilter)

    assert_equal ' 1000$ ', Template.parse("{{ var | money }}").render(@context)
  end

  def test_underscore_in_filter_name
    @context['var'] = 1000
    @context.add_filters(MoneyFilter)
    assert_equal ' 1000$ ', Template.parse("{{ var | money_with_underscore }}").render(@context)
  end

  def test_second_filter_overwrites_first
    @context['var'] = 1000
    @context.add_filters(MoneyFilter)
    @context.add_filters(CanadianMoneyFilter)

    assert_equal ' 1000$ CAD ', Template.parse("{{ var | money }}").render(@context)
  end

  def test_size
    @context['var'] = 'abcd'
    @context.add_filters(MoneyFilter)

    assert_equal 4, Variable.new("var | size").evaluate(@context)
  end

  def test_join
    @context['var'] = [1,2,3,4]

    assert_equal "1 2 3 4", Template.parse("{{ var | join }}").render(@context)
  end

  def test_sort
    @context['value'] = 3
    @context['numbers'] = [2,1,4,3]
    @context['words'] = ['expected', 'as', 'alphabetic']
    @context['arrays'] = [['flattened'], ['are']]

    assert_equal [1,2,3,4], Variable.new("numbers | sort").evaluate(@context)
    assert_equal ['alphabetic', 'as', 'expected'], Variable.new("words | sort").evaluate(@context)
    assert_equal [3], Variable.new("value | sort").evaluate(@context)
    assert_equal ['are', 'flattened'], Variable.new("arrays | sort").evaluate(@context)
  end

  def test_strip_html
    @context['var'] = "<b>bla blub</a>"

    assert_equal "bla blub", Template.parse("{{ var | strip_html }}").render(@context)
  end

  def test_strip_html_ignore_comments_with_html
    @context['var'] = "<!-- split and some <ul> tag --><b>bla blub</a>"

    assert_equal "bla blub", Template.parse("{{ var | strip_html }}").render(@context)
  end

  def test_capitalize
    @context['var'] = "blub"

    assert_equal "Blub", Template.parse("{{ var | capitalize }}").render(@context)
  end

  def test_nonexistent_filter_is_ignored
    @context['var'] = 1000

    assert_equal 1000, Variable.new("var | xyzzy").evaluate(@context)
  end

  def test_filter_with_keyword_arguments
    @context['surname'] = 'john'
    @context.add_filters(SubstituteFilter)
    output = Variable.new(%! 'hello %{first_name}, %{last_name}' | substitute: first_name: surname, last_name: 'doe' !).evaluate(@context)
    assert_equal 'hello john, doe', output
  end
end

class FiltersInTemplate < Test::Unit::TestCase
  include Liquid

  def test_local_global
    Template.register_filter(MoneyFilter)

    assert_equal " 1000$ ", Template.parse("{{1000 | money}}").render(nil, nil)
    assert_equal " 1000$ CAD ", Template.parse("{{1000 | money}}").render(nil, :filters => CanadianMoneyFilter)
    assert_equal " 1000$ CAD ", Template.parse("{{1000 | money}}").render(nil, :filters => [CanadianMoneyFilter])
  end

  def test_local_filter_with_deprecated_syntax
    assert_equal " 1000$ CAD ", Template.parse("{{1000 | money}}").render(nil, CanadianMoneyFilter)
    assert_equal " 1000$ CAD ", Template.parse("{{1000 | money}}").render(nil, [CanadianMoneyFilter])
  end
end # FiltersTest
