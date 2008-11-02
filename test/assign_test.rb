require File.dirname(__FILE__) + '/helper'

class IfElseTest < Test::Unit::TestCase
  include Liquid
  
  def test_with_filtered_expressions
    assert_template_result('foo','{% assign foo = values|sort|last %}{{ foo }}', 'values' => %w{foo bar baz})
    assert_template_result('foo','{% assign sorted = values|sort %}{{ sorted | last }}', 'values' => %w{foo bar baz})
  end

end