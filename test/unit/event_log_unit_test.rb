# frozen_string_literal: true

require 'test_helper'

class EventLogUnitTest < Minitest::Test
  def setup
    @event_log = Liquid::TemplateRecorder::EventLog.new
  end

  def test_add_drop_read
    @event_log.add_drop_read("product.name", "Test Product")
    @event_log.add_drop_read("product.price", 29.99)
    
    assigns = @event_log.finalize_to_assigns_tree
    
    assert_equal "Test Product", assigns["product"]["name"]
    assert_equal 29.99, assigns["product"]["price"]
  end

  def test_add_filter_call
    @event_log.add_filter_call("upcase", "hello", [], "HELLO")
    @event_log.add_filter_call("append", "world", ["!"], "world!")
    
    filters = @event_log.filter_calls
    
    assert_equal 2, filters.length
    assert_equal "upcase", filters[0][:name]
    assert_equal "hello", filters[0][:input]
    assert_equal "HELLO", filters[0][:output]
    
    assert_equal "append", filters[1][:name]
    assert_equal "world", filters[1][:input]
    assert_equal ["!"], filters[1][:args]
    assert_equal "world!", filters[1][:output]
  end

  def test_add_loop_event
    @event_log.add_loop_event(:enter, { collection_path: "products" })
    @event_log.add_loop_event(:item, { index: 0, item_object_id: 12345 })
    @event_log.add_loop_event(:exit, {})
    
    stats = @event_log.stats
    assert_equal 3, stats[:loop_events]
  end

  def test_add_file_read
    @event_log.add_file_read("header", "Welcome {{ user.name }}!")
    @event_log.add_file_read("footer", "© 2023")
    
    files = @event_log.file_reads
    
    assert_equal 2, files.length
    assert_equal "Welcome {{ user.name }}!", files["header"]
    assert_equal "© 2023", files["footer"]
  end

  def test_finalize_nested_structure
    @event_log.add_drop_read("product.variants[0].name", "Small")
    @event_log.add_drop_read("product.variants[0].price", 19.99)
    @event_log.add_drop_read("product.variants[1].name", "Large")
    @event_log.add_drop_read("product.variants[1].price", 29.99)
    @event_log.add_drop_read("product.title", "Test Product")
    
    assigns = @event_log.finalize_to_assigns_tree
    
    assert_equal "Test Product", assigns["product"]["title"]
    assert_equal 2, assigns["product"]["variants"].length
    
    assert_equal "Small", assigns["product"]["variants"][0]["name"]
    assert_equal 19.99, assigns["product"]["variants"][0]["price"]
    
    assert_equal "Large", assigns["product"]["variants"][1]["name"]
    assert_equal 29.99, assigns["product"]["variants"][1]["price"]
  end

  def test_finalize_complex_paths
    @event_log.add_drop_read("categories[0].products[0].variants[0].name", "Red Small")
    @event_log.add_drop_read("categories[0].products[0].variants[1].name", "Blue Small")
    @event_log.add_drop_read("categories[0].products[1].name", "Product 2")
    @event_log.add_drop_read("categories[1].name", "Category 2")
    
    assigns = @event_log.finalize_to_assigns_tree
    
    category0 = assigns["categories"][0]
    product0 = category0["products"][0]
    
    assert_equal "Red Small", product0["variants"][0]["name"]
    assert_equal "Blue Small", product0["variants"][1]["name"]
    assert_equal "Product 2", category0["products"][1]["name"]
    assert_equal "Category 2", assigns["categories"][1]["name"]
  end

  def test_serializable_values_only
    @event_log.add_drop_read("valid.string", "hello")
    @event_log.add_drop_read("valid.number", 42)
    @event_log.add_drop_read("valid.boolean", true)
    @event_log.add_drop_read("valid.null", nil)
    @event_log.add_drop_read("valid.array", [1, 2, 3])
    @event_log.add_drop_read("valid.hash", { "key" => "value" })
    
    # These should be ignored
    @event_log.add_drop_read("invalid.object", Object.new)
    @event_log.add_drop_read("invalid.symbol", :symbol)
    
    assigns = @event_log.finalize_to_assigns_tree
    
    assert assigns["valid"]["string"]
    assert assigns["valid"]["number"]
    assert assigns["valid"]["boolean"]
    assert assigns["valid"].key?("null")
    assert assigns["valid"]["array"]
    assert assigns["valid"]["hash"]
    
    refute assigns.key?("invalid")
  end

  def test_path_parsing
    event_log = @event_log
    
    # Test simple property
    parts = event_log.send(:parse_path, "product.name")
    assert_equal 2, parts.length
    assert_equal :property, parts[0][:type]
    assert_equal "product", parts[0][:key]
    assert_equal :property, parts[1][:type]
    assert_equal "name", parts[1][:key]
    
    # Test array access
    parts = event_log.send(:parse_path, "products[0].name")
    assert_equal 2, parts.length
    assert_equal :array_access, parts[0][:type]
    assert_equal "products", parts[0][:key]
    assert_equal 0, parts[0][:index]
    assert_equal :property, parts[1][:type]
    assert_equal "name", parts[1][:key]
  end

  def test_stats
    @event_log.add_drop_read("test", "value")
    @event_log.add_filter_call("test", "input", [], "output")
    @event_log.add_loop_event(:enter, {})
    @event_log.add_file_read("test", "content")
    
    stats = @event_log.stats
    
    assert_equal 1, stats[:drop_reads]
    assert_equal 1, stats[:filter_calls]
    assert_equal 1, stats[:loop_events]
    assert_equal 1, stats[:file_reads]
  end

  def test_clear
    @event_log.add_drop_read("test", "value")
    @event_log.add_filter_call("test", "input", [], "output")
    @event_log.add_loop_event(:enter, {})
    @event_log.add_file_read("test", "content")
    
    @event_log.clear!
    
    stats = @event_log.stats
    assert_equal 0, stats[:drop_reads]
    assert_equal 0, stats[:filter_calls]
    assert_equal 0, stats[:loop_events]
    assert_equal 0, stats[:file_reads]
  end

  def test_duplicate_path_handling
    # Last value should win for duplicate paths
    @event_log.add_drop_read("product.name", "First Name")
    @event_log.add_drop_read("product.name", "Second Name")
    
    assigns = @event_log.finalize_to_assigns_tree
    assert_equal "Second Name", assigns["product"]["name"]
  end

  def test_empty_path_handling
    # Should not crash with nil or empty paths
    @event_log.add_drop_read(nil, "value")
    @event_log.add_drop_read("", "value")
    
    assigns = @event_log.finalize_to_assigns_tree
    
    # Should not add invalid entries
    refute assigns.key?("")
    refute assigns.key?(nil)
  end
end