# frozen_string_literal: true

require 'test_helper'

class RegexpUnitTest < Minitest::Test
  include Liquid

  def test_empty
    assert_equal [], ''.scan(QUOTED_FRAGMENT)
  end

  def test_quote
    assert_equal ['"arg 1"'], '"arg 1"'.scan(QUOTED_FRAGMENT)
  end

  def test_words
    assert_equal ['arg1', 'arg2'], 'arg1 arg2'.scan(QUOTED_FRAGMENT)
  end

  def test_tags
    assert_equal ['<tr>', '</tr>'], '<tr> </tr>'.scan(QUOTED_FRAGMENT)
    assert_equal ['<tr></tr>'], '<tr></tr>'.scan(QUOTED_FRAGMENT)
    assert_equal ['<style', 'class="hello">', '</style>'], %(<style class="hello">' </style>).scan(QUOTED_FRAGMENT)
  end

  def test_double_quoted_words
    assert_equal ['arg1', 'arg2', '"arg 3"'], 'arg1 arg2 "arg 3"'.scan(QUOTED_FRAGMENT)
  end

  def test_single_quoted_words
    assert_equal ['arg1', 'arg2', "'arg 3'"], 'arg1 arg2 \'arg 3\''.scan(QUOTED_FRAGMENT)
  end

  def test_quoted_words_in_the_middle
    assert_equal ['arg1', 'arg2', '"arg 3"', 'arg4'], 'arg1 arg2 "arg 3" arg4   '.scan(QUOTED_FRAGMENT)
  end

  def test_variable_parser
    assert_equal ['var'],                               'var'.scan(VARIABLE_PARSER)
    assert_equal ['var', 'method'],                     'var.method'.scan(VARIABLE_PARSER)
    assert_equal ['var', '[method]'],                   'var[method]'.scan(VARIABLE_PARSER)
    assert_equal ['var', '[method]', '[0]'],            'var[method][0]'.scan(VARIABLE_PARSER)
    assert_equal ['var', '["method"]', '[0]'],          'var["method"][0]'.scan(VARIABLE_PARSER)
    assert_equal ['var', '[method]', '[0]', 'method'],  'var[method][0].method'.scan(VARIABLE_PARSER)
  end
end # RegexpTest
