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
end
