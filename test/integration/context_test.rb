require 'test_helper'

class ContextTest < Test::Unit::TestCase
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

    Template.register_filter(global)
    assert_equal 'Global test', Template.parse("{{'test' | notice }}").render!
    assert_equal 'Local test', Template.parse("{{'test' | notice }}").render!({}, :filters => [local])
  end

  def test_has_key_will_not_add_an_error_for_missing_keys
    Template.error_mode = :strict

    context = Context.new

    context.has_key?('unknown')

    assert_empty context.errors
  end
end
