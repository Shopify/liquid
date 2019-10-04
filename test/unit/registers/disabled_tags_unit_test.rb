# frozen_string_literal: true

require 'test_helper'

class DisabledTagsUnitTest < Minitest::Test
  include Liquid

  def test_disables_tag_specified
    register = DisabledTags.new
    register.disable(%w(foo bar)) do
      assert_equal true, register.disabled?("foo")
      assert_equal true, register.disabled?("bar")
      assert_equal false, register.disabled?("unknown")
    end
  end

  def test_disables_nested_tags
    register = DisabledTags.new
    register.disable(["foo"]) do
      register.disable(["foo"]) do
        assert_equal true, register.disabled?("foo")
        assert_equal false, register.disabled?("bar")
      end
      register.disable(["bar"]) do
        assert_equal true, register.disabled?("foo")
        assert_equal true, register.disabled?("bar")
        register.disable(["foo"]) do
          assert_equal true, register.disabled?("foo")
          assert_equal true, register.disabled?("bar")
        end
      end
      assert_equal true, register.disabled?("foo")
      assert_equal false, register.disabled?("bar")
    end
  end
end
