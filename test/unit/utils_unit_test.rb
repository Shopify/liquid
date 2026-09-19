# frozen_string_literal: true

require 'test_helper'

class UtilsUnitTest < Minitest::Test
  def test_inspect_with_no_arguments_uses_module_inspect
    assert_equal("Liquid::Utils", Liquid::Utils.inspect)
  end

  def test_to_s_with_no_arguments_uses_module_to_s
    assert_equal("Liquid::Utils", Liquid::Utils.to_s)
  end

  def test_inspect_still_renders_objects
    assert_equal("nil", Liquid::Utils.inspect(nil))
    assert_equal("{\"a\"=>1}", Liquid::Utils.inspect({ "a" => 1 }))
  end

  def test_to_s_still_renders_objects
    assert_equal("", Liquid::Utils.to_s(nil))
    assert_equal("{\"a\"=>1}", Liquid::Utils.to_s({ "a" => 1 }))
  end
end
