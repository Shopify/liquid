require 'test_helper'

class VariableUnitTest < Minitest::Test
  include Liquid

  def test_variable
    var = Variable.new('hello')
    assert_equal 'hello', var.name
  end

  def test_filters
    var = Variable.new('hello | textileze')
    assert_equal 'hello', var.name
    assert_equal [["textileze",[]]], var.filters

    var = Variable.new('hello | textileze | paragraph')
    assert_equal 'hello', var.name
    assert_equal [["textileze",[]], ["paragraph",[]]], var.filters

    var = Variable.new(%! hello | strftime: '%Y'!)
    assert_equal 'hello', var.name
    assert_equal [["strftime",["'%Y'"]]], var.filters

    var = Variable.new(%! 'typo' | link_to: 'Typo', true !)
    assert_equal %!'typo'!, var.name
    assert_equal [["link_to",["'Typo'", "true"]]], var.filters

    var = Variable.new(%! 'typo' | link_to: 'Typo', false !)
    assert_equal %!'typo'!, var.name
    assert_equal [["link_to",["'Typo'", "false"]]], var.filters

    var = Variable.new(%! 'foo' | repeat: 3 !)
    assert_equal %!'foo'!, var.name
    assert_equal [["repeat",["3"]]], var.filters

    var = Variable.new(%! 'foo' | repeat: 3, 3 !)
    assert_equal %!'foo'!, var.name
    assert_equal [["repeat",["3","3"]]], var.filters

    var = Variable.new(%! 'foo' | repeat: 3, 3, 3 !)
    assert_equal %!'foo'!, var.name
    assert_equal [["repeat",["3","3","3"]]], var.filters

    var = Variable.new(%! hello | strftime: '%Y, okay?'!)
    assert_equal 'hello', var.name
    assert_equal [["strftime",["'%Y, okay?'"]]], var.filters

    var = Variable.new(%! hello | things: "%Y, okay?", 'the other one'!)
    assert_equal 'hello', var.name
    assert_equal [["things",["\"%Y, okay?\"","'the other one'"]]], var.filters
  end

  def test_filter_with_date_parameter

    var = Variable.new(%! '2006-06-06' | date: "%m/%d/%Y"!)
    assert_equal "'2006-06-06'", var.name
    assert_equal [["date",["\"%m/%d/%Y\""]]], var.filters

  end

  def test_filters_without_whitespace
    var = Variable.new('hello | textileze | paragraph')
    assert_equal 'hello', var.name
    assert_equal [["textileze",[]], ["paragraph",[]]], var.filters

    var = Variable.new('hello|textileze|paragraph')
    assert_equal 'hello', var.name
    assert_equal [["textileze",[]], ["paragraph",[]]], var.filters

    var = Variable.new("hello|replace:'foo','bar'|textileze")
    assert_equal 'hello', var.name
    assert_equal [["replace", ["'foo'", "'bar'"]], ["textileze", []]], var.filters
  end

  def test_symbol
    var = Variable.new("http://disney.com/logo.gif | image: 'med' ", :error_mode => :lax)
    assert_equal "http://disney.com/logo.gif", var.name
    assert_equal [["image",["'med'"]]], var.filters
  end

  def test_string_to_filter
    var = Variable.new("'http://disney.com/logo.gif' | image: 'med' ")
    assert_equal "'http://disney.com/logo.gif'", var.name
    assert_equal [["image",["'med'"]]], var.filters
  end

  def test_string_single_quoted
    var = Variable.new(%| "hello" |)
    assert_equal '"hello"', var.name
  end

  def test_string_double_quoted
    var = Variable.new(%| 'hello' |)
    assert_equal "'hello'", var.name
  end

  def test_integer
    var = Variable.new(%| 1000 |)
    assert_equal "1000", var.name
  end

  def test_float
    var = Variable.new(%| 1000.01 |)
    assert_equal "1000.01", var.name
  end

  def test_string_with_special_chars
    var = Variable.new(%| 'hello! $!@.;"ddasd" ' |)
    assert_equal %|'hello! $!@.;"ddasd" '|, var.name
  end

  def test_string_dot
    var = Variable.new(%| test.test |)
    assert_equal 'test.test', var.name
  end

  def test_filter_with_keyword_arguments
    var = Variable.new(%! hello | things: greeting: "world", farewell: 'goodbye'!)
    assert_equal 'hello', var.name
    assert_equal [['things',["greeting: \"world\"","farewell: 'goodbye'"]]], var.filters
  end

  def test_lax_filter_argument_parsing
    var = Variable.new(%! number_of_comments | pluralize: 'comment': 'comments' !, :error_mode => :lax)
    assert_equal 'number_of_comments', var.name
    assert_equal [['pluralize',["'comment'","'comments'"]]], var.filters
  end

  def test_strict_filter_argument_parsing
    with_error_mode(:strict) do
      assert_raises(SyntaxError) do
        Variable.new(%! number_of_comments | pluralize: 'comment': 'comments' !)
      end
    end
  end
end
