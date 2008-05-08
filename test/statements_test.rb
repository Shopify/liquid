#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/helper'

class StatementsTest < Test::Unit::TestCase
  include Liquid


  def test_true_eql_true
    text = %| {% if true == true %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render
  end

  def test_true_not_eql_true
    text = %| {% if true != true %} true {% else %} false {% endif %} |
    expected = %|  false  |
    assert_equal expected, Template.parse(text).render
  end

  def test_true_lq_true
    text = %| {% if 0 > 0 %} true {% else %} false {% endif %} |
    expected = %|  false  |
    assert_equal expected, Template.parse(text).render
  end

  def test_one_lq_zero
    text = %| {% if 1 > 0 %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render
  end

  def test_zero_lq_one
    text = %| {% if 0 < 1 %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render
  end

  def test_zero_lq_or_equal_one
    text = %| {% if 0 <= 0 %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render
  end

  def test_zero_lq_or_equal_one_involving_nil
    text = %| {% if null <= 0 %} true {% else %} false {% endif %} |
    expected = %|  false  |
    assert_equal expected, Template.parse(text).render


    text = %| {% if 0 <= null %} true {% else %} false {% endif %} |
    expected = %|  false  |
    assert_equal expected, Template.parse(text).render
  end

  def test_zero_lqq_or_equal_one
    text = %| {% if 0 >= 0 %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render
  end

  def test_strings
    text = %| {% if 'test' == 'test' %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render
  end

  def test_strings_not_equal
    text = %| {% if 'test' != 'test' %} true {% else %} false {% endif %} |
    expected = %|  false  |
    assert_equal expected, Template.parse(text).render
  end
  
  def test_var_strings_equal
    text = %| {% if var == "hello there!" %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render('var' => 'hello there!')
  end
  
  def test_var_strings_are_not_equal
    text = %| {% if "hello there!" == var %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render('var' => 'hello there!')
  end
  
  def test_var_and_long_string_are_equal
    text = %| {% if var == 'hello there!' %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render('var' => 'hello there!')
  end
  

  def test_var_and_long_string_are_equal_backwards
    text = %| {% if 'hello there!' == var %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render('var' => 'hello there!')
  end
  
  #def test_is_nil    
  #  text = %| {% if var != nil %} true {% else %} false {% end %} |
  #  @template.assigns = { 'var' => 'hello there!'}
  #  expected = %|  true  |
  #  assert_equal expected, @template.parse(text)
  #end
    
  def test_is_collection_empty    
    text = %| {% if array == empty %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render('array' => [])
  end

  def test_is_not_collection_empty    
    text = %| {% if array == empty %} true {% else %} false {% endif %} |
    expected = %|  false  |
    assert_equal expected, Template.parse(text).render('array' => [1,2,3])
  end

  def test_nil
    text = %| {% if var == nil %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render('var' => nil)

    text = %| {% if var == null %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render('var' => nil)
  end

  def test_not_nil
    text = %| {% if var != nil %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render('var' => 1 )

    text = %| {% if var != null %} true {% else %} false {% endif %} |
    expected = %|  true  |
    assert_equal expected, Template.parse(text).render('var' => 1 )
  end

end