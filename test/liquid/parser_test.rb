require 'test_helper'


class ParserTest < Test::Unit::TestCase
  include Liquid


  def test_strings
    assert_equal [[:id, "string"]], Parser.parse('"string"')
    assert_equal [[:id, "string"]], Parser.parse('\'string\'')
  end

  def test_integer
    assert_equal [[:id, 1]], Parser.parse('1')
    assert_equal [[:id, 100001]], Parser.parse('100001')
  end

  def test_float
    assert_equal [[:id, 1.1]], Parser.parse('1.1')
    assert_equal [[:id, 1.55435]], Parser.parse('1.55435')
  end

  def test_null
    assert_equal [[:id, nil]], Parser.parse('null')
    assert_equal [[:id, nil]], Parser.parse('nil')
  end

  def test_bool
    assert_equal [[:id, true]], Parser.parse('true')
    assert_equal [[:id, false]], Parser.parse('false')
  end

  def test_ranges
    assert_equal [[:id, 1], [:id, 5], [:range, nil]], Parser.parse('(1..5)')
    assert_equal [[:id, 100], [:id, 500], [:range, nil]], Parser.parse('(100..500)')    
  end

  def test_ranges_with_lookups
    assert_equal [[:id, 1], [:id, "test"], [:lookup, nil], [:range, nil]], Parser.parse('(1..test)')
  end

  def test_lookups
    assert_equal [[:id, "variable"], [:lookup, nil]], Parser.parse('variable')
    assert_equal [[:id, "underscored_variable"], [:lookup, nil]], Parser.parse('underscored_variable')
  end

  def test_global_hash
    assert_equal [[:id, true], [:lookup, nil]], Parser.parse('[true]')

    assert_equal [[:id, "string"], [:lookup, nil]], Parser.parse('["string"]')
    assert_equal [[:id, 5.55], [:lookup, nil]], Parser.parse('[5.55]')
    assert_equal [[:id, 0], [:lookup, nil]], Parser.parse('[0]')
    assert_equal [[:id, "variable"], [:lookup, nil], [:lookup, nil]], Parser.parse('[variable]')
  end

  # def test_descent
#   assert_equal [[:id, "variable1"], [:lookup, nil], [:id, "variable2"], [:call, nil]], Parser.parse('variable1.varible2')
  # end

  # def test_descent_hash
  #   assert_equal [[:id, "variable1"], [:lookup, nil], [:id, "variable2"], [:call, nil]], Parser.parse('variable1["varible2"]')  
  #   assert_equal [[:id, "variable1"], [:lookup, nil], [:id, "variable2"], [:lookup, "variable2"], [:call, nil]], Parser.parse('variable1[varible2]')
  # end


end
