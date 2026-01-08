# frozen_string_literal: true

require 'test_helper'

class BindingTrackerUnitTest < Minitest::Test
  def setup
    @tracker = Liquid::TemplateRecorder::BindingTracker.new
  end

  def test_bind_and_resolve_root_object
    obj = Object.new
    @tracker.bind_root_object(obj, "product")
    
    assert_equal "product", @tracker.resolve_binding_path(obj)
  end

  def test_bind_and_resolve_loop_item
    obj = Object.new
    @tracker.bind_loop_item(obj, "products[0]")
    
    assert_equal "products[0]", @tracker.resolve_binding_path(obj)
  end

  def test_build_property_path
    obj = Object.new
    @tracker.bind_root_object(obj, "product")
    
    property_path = @tracker.build_property_path(obj, "name")
    assert_equal "product.name", property_path
  end

  def test_build_property_path_with_unbound_object
    obj = Object.new
    
    property_path = @tracker.build_property_path(obj, "name")
    assert_nil property_path
  end

  def test_loop_context_management
    refute @tracker.in_loop?
    assert_equal 0, @tracker.loop_depth
    
    @tracker.enter_loop("products")
    assert @tracker.in_loop?
    assert_equal 1, @tracker.loop_depth
    
    current_loop = @tracker.current_loop
    assert_equal "products", current_loop[:collection_path]
    
    @tracker.exit_loop
    refute @tracker.in_loop?
    assert_equal 0, @tracker.loop_depth
  end

  def test_nested_loops
    @tracker.enter_loop("categories")
    assert_equal 1, @tracker.loop_depth
    
    @tracker.enter_loop("categories[0].products")
    assert_equal 2, @tracker.loop_depth
    
    @tracker.exit_loop
    assert_equal 1, @tracker.loop_depth
    
    @tracker.exit_loop
    assert_equal 0, @tracker.loop_depth
  end

  def test_bind_current_loop_item
    @tracker.enter_loop("products")
    
    item1 = Object.new
    item2 = Object.new
    
    @tracker.bind_current_loop_item(0, item1)
    @tracker.bind_current_loop_item(1, item2)
    
    assert_equal "products[0]", @tracker.resolve_binding_path(item1)
    assert_equal "products[1]", @tracker.resolve_binding_path(item2)
    
    @tracker.exit_loop
  end

  def test_bind_current_loop_item_outside_loop
    item = Object.new
    
    # Should not crash when not in a loop
    @tracker.bind_current_loop_item(0, item)
    assert_nil @tracker.resolve_binding_path(item)
  end

  def test_handle_nil_objects
    @tracker.bind_root_object(nil, "test")
    assert_nil @tracker.resolve_binding_path(nil)
    
    @tracker.bind_loop_item(nil, "test[0]")
    assert_nil @tracker.resolve_binding_path(nil)
    
    assert_nil @tracker.build_property_path(nil, "name")
  end

  def test_clear_bindings
    obj = Object.new
    @tracker.bind_root_object(obj, "product")
    @tracker.enter_loop("items")
    
    assert @tracker.in_loop?
    assert_equal "product", @tracker.resolve_binding_path(obj)
    
    @tracker.clear!
    
    refute @tracker.in_loop?
    assert_nil @tracker.resolve_binding_path(obj)
  end

  def test_current_bindings
    obj1 = Object.new
    obj2 = Object.new
    
    @tracker.bind_root_object(obj1, "product")
    @tracker.bind_root_object(obj2, "user")
    
    bindings = @tracker.current_bindings
    
    assert_equal 2, bindings.size
    assert_equal "product", bindings[obj1.object_id]
    assert_equal "user", bindings[obj2.object_id]
    
    # Should be a copy, not the original
    bindings.clear
    assert_equal 2, @tracker.current_bindings.size
  end
end