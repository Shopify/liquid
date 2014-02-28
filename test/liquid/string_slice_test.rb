require 'test_helper'

class StringSliceTest < Test::Unit::TestCase
  def test_new_from_string
    assert_equal 'slice', Liquid::StringSlice.new("slice and dice", 0, 5).to_str
    assert_equal 'and', Liquid::StringSlice.new("slice and dice", 6, 3).to_str
    assert_equal 'dice', Liquid::StringSlice.new("slice and dice", 10, 4).to_str
    assert_equal 'slice and dice', Liquid::StringSlice.new("slice and dice", 0, 14).to_str
  end

  def test_new_from_slice
    slice1 = Liquid::StringSlice.new("slice and dice", 0, 14)
    slice2 = Liquid::StringSlice.new(slice1, 6, 8)
    slice3 = Liquid::StringSlice.new(slice2, 0, 3)
    assert_equal "slice and dice", slice1.to_str
    assert_equal "and dice", slice2.to_str
    assert_equal "and", slice3.to_str
  end

  def test_slice
    slice = Liquid::StringSlice.new("slice and dice", 2, 10)
    assert_equal "and", slice.slice(4, 3).to_str
  end

  def test_length
    slice = Liquid::StringSlice.new("slice and dice", 6, 3)
    assert_equal 3, slice.length
    assert_equal 3, slice.size
  end

  def test_equal
    assert_equal 'and', Liquid::StringSlice.new("slice and dice", 6, 3)
  end
end
