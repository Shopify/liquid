#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/helper'

class StrainerTest < Test::Unit::TestCase
  include Liquid

  def test_strainer
    strainer = Strainer.create(nil)
    assert_equal false, strainer.respond_to?('__test__')
    assert_equal false, strainer.respond_to?('test')
    assert_equal false, strainer.respond_to?('instance_eval')
    assert_equal false, strainer.respond_to?('__send__')
    assert_equal true, strainer.respond_to?('size') # from the standard lib
  end
  
end