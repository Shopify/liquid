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
end
