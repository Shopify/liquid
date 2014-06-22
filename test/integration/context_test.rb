require 'test_helper'

class ContextTest < Minitest::Test
  include Liquid

  def test_override_global_filter
    global = Module.new do
      def notice(output)
        "Global #{output}"
      end
    end

    local = Module.new do
      def notice(output)
        "Local #{output}"
      end
    end

    original_filters = Array.new(Strainer.class_eval('@@filters'))
    Template.register_filter(global)
    assert_equal 'Global test', Template.parse("{{'test' | notice }}").render!
    assert_equal 'Local test', Template.parse("{{'test' | notice }}").render!({}, :filters => [local])
  ensure
    Strainer.class_eval('@@filters = ' + original_filters.to_s)
  end
end
