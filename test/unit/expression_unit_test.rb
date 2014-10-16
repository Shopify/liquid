require 'test_helper'


class ExpressionUnitTest < Minitest::Test
  include Liquid

  def test_strings
    assert_equal [:id, "string"], parse('"string"')
    assert_equal [:id, "string"], parse('\'string\'')
  end

  def test_integer
    assert_equal [:id, 1], parse('1')
    assert_equal [:id, 100001], parse('100001')
  end

  def test_float
    assert_equal [:id, 1.1], parse('1.1')
    assert_equal [:id, 1.55435], parse('1.55435')
  end

  def test_null
    assert_equal [:id, nil], parse('null')
    assert_equal [:id, nil], parse('nil')
  end

  def test_bool
    assert_equal [:id, true], parse('true')
    assert_equal [:id, false], parse('false')
  end

  def test_ranges
    assert_equal [:id, 1, :id, 5, :range, nil], parse('(1..5)')
    assert_equal [:id, 100, :id, 500, :range, nil], parse('(100..500)')
  end

  def test_ranges_with_lookups
    assert_equal [:id, 1, :id, "test", :lookup, nil, :range, nil], parse('(1..test)')
  end

  def test_lookups
    assert_equal [:id, "variable", :lookup, nil], parse('variable')
    assert_equal [:id, "underscored_variable", :lookup, nil], parse('underscored_variable')
    assert_equal [:id, "c", :lookup, nil], parse('c')
  end

  def test_global_hash
    assert_equal [:id, true, :lookup, nil], parse('[true]')

    assert_equal [:id, "string", :lookup, nil], parse('["string"]')
    assert_equal [:id, 5.55, :lookup, nil], parse('[5.55]')
    assert_equal [:id, 0, :lookup, nil], parse('[0]')
    assert_equal [:id, "variable", :lookup, nil, :lookup, nil], parse('[variable]')
  end

  def test_descent
    assert_equal [:id, "variable1", :lookup, nil, :id, "variable2", :call, nil], parse('variable1.variable2')
    assert_equal [:id, "variable1", :lookup, nil, :id, "variable2", :call, nil, :id, "variable3", :call, nil], parse('variable1.variable2.variable3')
    assert_equal [:id, "variable1", :lookup, nil, :id, "under_score", :call, nil], parse('variable1.under_score')
    assert_equal [:id, "variable1", :lookup, nil, :id, "question?", :call, nil], parse('variable1.question?')
  end

  def test_descent_hash
    assert_equal [:id, "variable1", :lookup, nil, :id, "variable2", :call, nil], parse('variable1["variable2"]')
    assert_equal [:id, "variable1", :lookup, nil, :id, "variable2", :lookup, nil, :call, nil], parse('variable1[variable2]')
  end

  def test_builtin
    assert_equal [:id, "first", :lookup, nil], parse('first')

    assert_equal [:id, "var", :lookup, nil, :builtin, "first"], parse('var.first')
    assert_equal [:id, "var", :lookup, nil, :builtin, "last"], parse('var.last')
    assert_equal [:id, "var", :lookup, nil, :builtin, "size"], parse('var.size')
  end

  def test_descent_hash_descent
    assert_equal [:id, "variable1", :lookup, nil, :id, "test1", :lookup, nil, :id, "test2", :call, nil, :call, nil],
      parse('variable1[test1.test2]'), "resolve: variable1[test1.test2]"

    assert_equal [:id, "variable1", :lookup, nil, :id, "test1", :lookup, nil, :id, "test2", :call, nil, :call, nil],
      parse('variable1[test1["test2"]]'), 'resolve: variable1[test1["test2"]]'
  end

  private

  def parse(markup)
    expr = Expression.parse(markup)
    expr.instance_variable_get(:@instructions)
  end
end
