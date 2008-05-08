require File.dirname(__FILE__) + '/helper'
   
class RegexpTest < Test::Unit::TestCase
  include Liquid

  def test_empty
    assert_equal [], ''.scan(QuotedFragment)
  end
  
  def test_quote
    assert_equal ['"arg 1"'], '"arg 1"'.scan(QuotedFragment)
  end
  

  def test_words
    assert_equal ['arg1', 'arg2'], 'arg1 arg2'.scan(QuotedFragment)
  end

  def test_quoted_words
    assert_equal ['arg1', 'arg2', '"arg 3"'], 'arg1 arg2 "arg 3"'.scan(QuotedFragment)
  end

  def test_quoted_words
    assert_equal ['arg1', 'arg2', "'arg 3'"], 'arg1 arg2 \'arg 3\''.scan(QuotedFragment)
  end

  def test_quoted_words_in_the_middle
    assert_equal ['arg1', 'arg2', '"arg 3"', 'arg4'], 'arg1 arg2 "arg 3" arg4   '.scan(QuotedFragment)
  end
  
  def test_variable_parser
    assert_equal ['var'],                 'var'.scan(VariableParser)
    assert_equal ['var', 'method'],       'var.method'.scan(VariableParser)
    assert_equal ['var', '[method]'],       'var[method]'.scan(VariableParser)
    assert_equal ['var', '[method]', '[0]'],  'var[method][0]'.scan(VariableParser)
    assert_equal ['var', '["method"]', '[0]'],  'var["method"][0]'.scan(VariableParser)
    assert_equal ['var', '[method]', '[0]', 'method'],  'var[method][0].method'.scan(VariableParser)    
  end
 
end