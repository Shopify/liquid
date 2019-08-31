require 'test_helper'

class TryVariablesUsageTest < Minitest::Test
  include Liquid

  def test_test_usages
    Usage.enable
    template = Template.parse(%({{test}}))
    assert_equal 'worked', template.render!('test' => 'worked')
    assert_equal 'worked wonderfully', template.render!('test' => 'worked wonderfully')
    assert_equal true, Usage.results["Using try_variable_find_in_environment"]
    Usage.disable
  end
end
