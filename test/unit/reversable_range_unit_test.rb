require 'test_helper'

class ReversableRangeTest < Minitest::Test
  include Liquid

  def test_each_iterates_through_items_in_the_range
    actual_items = []
    ReversableRange.new(1, 10).each { |item| actual_items << item }

    expected_items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    assert_equal expected_items, actual_items
  end

  def test_implements_enumerable
    actual_items = ReversableRange.new(1, 10).select(&:even?)

    expected_items = [2, 4, 6, 8, 10]
    assert_equal expected_items, actual_items
  end

  def test_is_not_empty_max_greater_than_min
    range = ReversableRange.new(9, 10)

    refute_predicate range, :empty?
  end

  def test_is_not_empty_max_equal_to_min
    range = ReversableRange.new(10, 10)

    refute_predicate range, :empty?
  end

  def test_is_empty_if_not_reversed_and_max_less_than_min
    range = ReversableRange.new(10, 9)

    assert_predicate range, :empty?
  end

  def test_ranges_with_the_same_max_and_min_have_one_element
    actual_items = ReversableRange.new(1337, 1337).to_a
    expected_items = [1337]
    assert_equal expected_items, actual_items
  end

  def test_load_slice_returns_a_sub_range
    actual_items = ReversableRange.new(1, 10).load_slice(5, 8).to_a

    expected_items = [5, 6, 7, 8]
    assert_equal expected_items, actual_items
  end

  def test_load_slice_returns_a_reversed_sub_range_if_reversed
    range = ReversableRange.new(1, 10)
    range.reverse!
    actual_items = range.load_slice(5, 8).to_a

    expected_items = [8, 7, 6, 5]
    assert_equal expected_items, actual_items
  end

  def test_is_equal_to_other_if_also_a_reversable_range_and_has_same_properties
    one = ReversableRange.new(1, 10)
    one.reverse!

    two = ReversableRange.new(1, 10)
    two.reverse!

    assert_equal one, two
  end

  def test_is_not_equal_to_a_non_reversable_range
    range = ReversableRange.new(1, 10)
    range.reverse!

    refute_equal range, :something_else
  end

  def test_is_not_equal_if_ranges_have_different_mins
    one = ReversableRange.new(1, 10)
    two = ReversableRange.new(2, 10)

    refute_equal one, two
  end

  def test_is_not_equal_if_ranges_have_different_maxes
    one = ReversableRange.new(1, 10)
    two = ReversableRange.new(1, 11)

    refute_equal one, two
  end

  def test_is_not_equal_if_only_one_is_reversed
    one = ReversableRange.new(1, 10)

    two = ReversableRange.new(1, 10)
    two.reverse!

    refute_equal one, two
  end

  def test_to_s_mirrors_rubys_range_syntax
    range = ReversableRange.new(1, 10)
    assert_equal '1..10', range.to_s
  end

  def test_to_s_reverses_when_reversed
    range = ReversableRange.new(1, 10)
    range.reverse!
    assert_equal '10..1', range.to_s
  end

  def test_size
    range = ReversableRange.new(1, 10)
    assert_equal 10, range.size
  end
end
