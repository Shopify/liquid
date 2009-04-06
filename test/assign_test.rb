require File.dirname(__FILE__) + '/helper'

class AssignTest < Test::Unit::TestCase
  include Liquid
  
  def test_assigned_variable
    assert_template_result('.foo.','{% assign foo = values %}.{{ foo }}.', 'values' => %w{foo bar baz})
  end

end