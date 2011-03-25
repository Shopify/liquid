require 'test_helper'
require File.join File.dirname(__FILE__), '..', '..', 'lib','extras', 'liquid_view'


class AssignTest < Test::Unit::TestCase 
  def test_default_included_helpers_is_nil
    LiquidView.send(:class_variable_set, "@@included_helpers",nil)
    assert_equal nil, LiquidView.included_helpers
  end
  
  def test_set_included_helpers 
    m = Module.new {}
    LiquidView.included_helpers = [m] 
    assert_equal [m], LiquidView.included_helpers
  end

  def test_covert_included_helpers_to_array_if_it_is_not 
    m = Module.new {}
    LiquidView.included_helpers = m
    assert_equal [m], LiquidView.included_helpers
  end
  

  def test_filters_should_be_master_helper_module_if_no_custom_helper_set
    lv = LiquidView.new(nil)
    LiquidView.included_helpers = nil 
    master_helper_module = Module.new {}
    assert_equal [master_helper_module], lv.filters(m)
  end

  def test_filters_should_be_master_helper_module_if_no_custom_helper_set
    lv = LiquidView.new(nil)
    master_helper_module = Module.new {}
    custom_helper = Module.new {}
    LiquidView.included_helpers = [custom_helper]
    assert_equal [custom_helper], lv.filters(master_helper_module)
  end
end
