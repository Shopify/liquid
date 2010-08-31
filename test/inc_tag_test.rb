require File.dirname(__FILE__) + '/helper'


class IncTagTest < Test::Unit::TestCase
  include Liquid
  
  def test_inc
    assert_template_result('0','{%inc port %}', {})
    assert_template_result('0 1','{%inc port %} {%inc port%}', {})
    assert_template_result('0 0 1 2 1',
                           '{%inc port %} {%inc starboard%} ' +
                           '{%inc port %} {%inc port%} ' +
                           '{%inc starboard %}', {})
  end
  
end
