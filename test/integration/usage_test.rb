require 'test_helper'

module Liquid
  class TestUsage < Usage
    @messages = {}
    class << self
      def enable
        Dir["#{__dir__}/usages/*.rb"].each { |f| require f }
      end
    end
  end
end

class UsageTest < Minitest::Test
  include Liquid

  Usage.enable

  def test_test_usages
    Dir["#{__dir__}/usages/*.rb"].each { |f| require f }

    template = Template.parse(%({{test}}))
    assert_equal 'worked', template.render!('test' => 'worked')
    assert_equal 'worked wonderfully', template.render!('test' => 'worked wonderfully')
    assert_equal true, Usage.results["Using try_variable_find_in_environment"]
  end

  def test_live_usages
    template = Template.parse(%({{test}}))
    assert_equal 'worked', template.render!('test' => 'worked')
    assert_equal 'worked wonderfully', template.render!('test' => 'worked wonderfully')
    assert_equal true, Usage.results["Usage is enabled"]
  end
end
