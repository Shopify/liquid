require 'test_helper'

class UsageEnabledUsageTest < Minitest::Test
  include Liquid

  def test_live_usages
    assert_equal true, Usage.results["Usage is enabled"]
  end
end
