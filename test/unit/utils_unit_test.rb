# frozen_string_literal: true

require 'test_helper'

class UtilsUnitTest < Minitest::Test
  def test_inspect_without_arguments_calls_super
    assert_equal("Liquid::Utils", Liquid::Utils.inspect)
  end

  def test_inspect_with_object
    assert_equal('"hello"', Liquid::Utils.inspect("hello"))
    assert_equal('123', Liquid::Utils.inspect(123))
    assert_equal('[1, 2]', Liquid::Utils.inspect([1, 2]))
    assert_equal('{"a"=>1}', Liquid::Utils.inspect({ "a" => 1 }))
    assert_equal('nil', Liquid::Utils.inspect(nil))
  end

  def test_to_s_without_arguments_calls_super
    assert_equal("Liquid::Utils", Liquid::Utils.to_s)
  end

  def test_to_s_with_object
    assert_equal("hello", Liquid::Utils.to_s("hello"))
    assert_equal("123", Liquid::Utils.to_s(123))
    assert_equal("[1, 2]", Liquid::Utils.to_s([1, 2]))
    assert_equal('{"a"=>1}', Liquid::Utils.to_s({ "a" => 1 }))
  end
end
