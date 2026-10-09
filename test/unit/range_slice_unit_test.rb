# frozen_string_literal: true

require 'test_helper'

class RangeSliceUnitTest < Minitest::Test
  def test_selects_and_reverses_an_integer_range_without_enumerating_it
    limits = Liquid::ResourceLimits.new({})
    slice = Liquid::RangeSlice.new(bounded_integer_range_with_tripwires, 997, 999, limits)

    assert_equal(2, slice.length)
    refute(slice.empty?)
    slice.reverse!
    assert_equal([999, 998], slice.each.to_a)
    assert_equal(2, limits.render_score)
  end

  def test_charges_only_values_yielded_before_a_break
    limits = Liquid::ResourceLimits.new({})
    slice = Liquid::RangeSlice.new(bounded_integer_range_with_tripwires, 0, nil, limits)

    slice.each { break }

    assert_equal(1, limits.render_score)
  end

  def test_non_integer_ranges_are_sliced_without_to_a_and_charge_visited_values
    limits = Liquid::ResourceLimits.new({})
    range = Class.new(Range) do
      def to_a
        raise 'range was materialized'
      end
    end.new('a', 'c')

    assert_equal(['b', 'c'], Liquid::Utils.slice_collection_for_iteration(range, 1, nil, limits))
    assert_equal(3, limits.render_score)

    limited = Liquid::ResourceLimits.new(render_score_limit: 2)
    assert_raises(Liquid::MemoryError) do
      Liquid::Utils.slice_collection_for_iteration('a'..'z', 10, 11, limited)
    end
  end

  def test_non_integer_range_empty_windows_do_not_visit_a_sentinel_value
    limits = Liquid::ResourceLimits.new({})

    assert_equal([], Liquid::Utils.slice_collection_for_iteration('a'..'z', 2, 2, limits))
    assert_equal(0, limits.render_score)
    assert_equal(['a', 'b'], Liquid::Utils.slice_collection_for_iteration('a'..'z', 0, 2, limits))
    assert_equal(2, limits.render_score)
  end

  def test_standard_beginless_range_raises_for_empty_windows
    [[0, 0], [1, 0]].each do |from, to|
      assert_raises(TypeError) do
        Liquid::Utils.slice_collection_for_iteration(Range.new(nil, 3), from, to, Liquid::ResourceLimits.new({}))
      end
    end
  end

  def test_custom_range_to_a_is_sliced_with_a_budget
    range = Class.new(Range) do
      def to_a
        [1, 2, 3]
      end
    end.new(nil, 3)
    limits = Liquid::ResourceLimits.new(render_score_limit: 2)

    assert_raises(Liquid::MemoryError) do
      Liquid::Utils.slice_collection_for_iteration(range, 1, 3, limits, use_range_to_a: true)
    end
    assert_equal(3, limits.render_score)
  end

  def test_preserves_slice_bounds_for_negative_offsets_and_limits
    limits = Liquid::ResourceLimits.new({})

    assert_equal([1, 2], Liquid::RangeSlice.new(1..5, -2, 2, limits).each.to_a)
    empty = Liquid::RangeSlice.new(1..5, 2, 1, limits)
    assert(empty.empty?)
    assert_equal([], empty.each.to_a)
    assert_equal(2, limits.render_score) # the empty window performs no work
    assert(Liquid::RangeSlice.new(5..1, 0, nil, limits).empty?)
    assert_equal([1, 2, 3, 4], Liquid::RangeSlice.new(1...5, 0, nil, limits).each.to_a)
  end
end
