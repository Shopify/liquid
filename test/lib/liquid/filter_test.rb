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

module InspectFilter
  def inspect(input, *args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    [
      "input: #{input.inspect}",
      "args:",
      args.map { |arg| "#{arg.inspect}" }.join(", "),
      "opts: {",
      opts.keys.sort.map { |key| "#{key.inspect}=>#{opts[key].inspect}" }.join(", "),
      "}"
    ].flatten.join(" ")
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

    assert_equal ' 1000$ ', Variable.new("var | money").render(@context)
  end

  def test_underscore_in_filter_name
    @context['var'] = 1000
    @context.add_filters(MoneyFilter)
    assert_equal ' 1000$ ', Variable.new("var | money_with_underscore").render(@context)
  end

  def test_second_filter_overwrites_first
    @context['var'] = 1000
    @context.add_filters(MoneyFilter)
    @context.add_filters(CanadianMoneyFilter)

    assert_equal ' 1000$ CAD ', Variable.new("var | money").render(@context)
  end

  def test_size
    @context['var'] = 'abcd'
    @context.add_filters(MoneyFilter)

    assert_equal 4, Variable.new("var | size").render(@context)
  end

  def test_join
    @context['var'] = [1,2,3,4]

    assert_equal "1 2 3 4", Variable.new("var | join").render(@context)
  end

  def test_sort
    @context['value'] = 3
    @context['numbers'] = [2,1,4,3]
    @context['words'] = ['expected', 'as', 'alphabetic']
    @context['arrays'] = [['flattened'], ['are']]

    assert_equal [1,2,3,4], Variable.new("numbers | sort").render(@context)
    assert_equal ['alphabetic', 'as', 'expected'], Variable.new("words | sort").render(@context)
    assert_equal [3], Variable.new("value | sort").render(@context)
    assert_equal ['are', 'flattened'], Variable.new("arrays | sort").render(@context)
  end

  def test_strip_html
    @context['var'] = "<b>bla blub</a>"

    assert_equal "bla blub", Variable.new("var | strip_html").render(@context)
  end

  def test_capitalize
    @context['var'] = "blub"

    assert_equal "Blub", Variable.new("var | capitalize").render(@context)
  end

  def test_nonexistent_filter_is_ignored
    @context['var'] = 1000

    assert_equal 1000, Variable.new("var | xyzzy").render(@context)
  end

  def test_filter_arguments
    @context['var'] = 'input'
    @context.add_filters(InspectFilter)
    assert_equal 'input: "input" args: 1, "two" opts: { "three"=>3 }',
      Variable.new("var | inspect: 1, 'two', three: 3").render(@context)
    assert_equal 'input: "input" args: 1, 2 opts: { "a"=>1, "b"=>2, "c"=>3 }',
      Variable.new("var | inspect: 1, 2, a: 1, b: 2, c: 3").render(@context)
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
