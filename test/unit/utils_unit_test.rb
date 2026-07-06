# frozen_string_literal: true

require 'test_helper'

class UtilsUnitTest < Minitest::Test
  include Liquid

  def test_to_number_with_float
    assert_equal(BigDecimal("0.1"), Utils.to_number(0.1))
  end

  def test_to_number_with_numeric
    assert_equal(1, Utils.to_number(1))
  end

  def test_to_number_with_string
    assert_equal(123, Utils.to_number("123"))
  end

  def test_to_number_with_precision_string
    assert_equal(BigDecimal("0.1"), Utils.to_number("0.1"))
  end

  def test_to_number_with_exponential
    # TODO: Fix wrong behaviour
    assert_equal(2, Utils.to_number("2**4"))
  end

  def test_to_integer_with_integer
    assert_equal(1, Utils.to_integer(1))
  end

  def test_to_integer_with_string
    assert_equal(1, Utils.to_integer("1"))
  end

  def test_to_integer_with_invalid_argument
    assert_raises(Liquid::ArgumentError) do
      Utils.to_integer("FOOBAR")
    end
  end

  def test_to_date_with_time
    t = Time.new(2019, 01, 01, 12, 00, 00, "+00:00")
    assert_equal(t, Utils.to_date(t))
  end

  def test_to_date_with_now
    t = Time.new(2019, 01, 01, 12, 00, 00, "+00:00")
    Time.stub(:now, t) do
      assert_equal(t, Utils.to_date("now"))
    end
  end

  def test_to_date_with_timestamp
    t = Time.new(2019, 01, 01, 12, 00, 00, "+00:00")
    assert_equal(t, Utils.to_date(t.to_i))
  end

  def test_to_date_with_string
    skip "minitest mock is failing to stub offset"
    t = Time.new(2019, 01, 01, 12, 00, 00, "-02:00")
    Time.stub(:now, t) do
      assert_equal("2019-01-01 16:00:00 -0200", Utils.to_date("16:00"))
    end
  end

  def test_to_date_with_invalid_string
    assert_equal(nil, Utils.to_date("FOOBAR"))
  end

  def test_slice_collection_using_each_with_string
    assert_equal(["tag"], Utils.slice_collection_using_each("tag", 0, 2))
  end

  def test_slice_collection_using_each_with_empty_string
    assert_equal([], Utils.slice_collection_using_each("", 0, 3))
  end

  def test_slice_collection_using_each_with_array
    assert_equal([0, 1, 2, 3], Utils.slice_collection_using_each([0, 1, 2, 3, 4, 5], 0, 4))
  end

  def test_slice_collection_using_each_with_no_range
    assert_equal([], Utils.slice_collection_using_each([0, 1, 2, 3, 4, 5], 0, 0))
  end

  def test_slice_collection_using_each_with_middle_range
    assert_equal([2], Utils.slice_collection_using_each([0, 1, 2, 3, 4, 5], 2, 3))
  end

  def test_slice_collection_using_each_with_integer
    assert_equal([], Utils.slice_collection_using_each(1, 0, 1))
  end

  def test_slice_collection_using_each_with_negative_start
    assert_equal([0, 1], Utils.slice_collection_using_each([0, 1, 2, 3], -1, 2))
  end

  def test_slice_collection_using_each_with_negative_end
    assert_equal([], Utils.slice_collection_using_each([0, 1, 2, 3], 1, -2))
  end
end
