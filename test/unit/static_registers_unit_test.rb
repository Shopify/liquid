require 'test_helper'

class StaticRegistersUnitTest < Minitest::Test
  include Liquid

  def set
    static_register = StaticRegisters.new
    static_register[nil] = true
    static_register[1] = :one
    static_register[:one] = "one"
    static_register["two"] = "three"
    static_register["two"] = 3
    static_register[false] = nil

    assert_equal({ nil => true, 1 => :one, :one => "one", "two" => 3, false => nil }, static_register.registers)

    static_register
  end

  def test_get
    static_register = set

    assert_equal true, static_register[nil]
    assert_equal :one, static_register[1]
    assert_equal "one", static_register[:one]
    assert_equal 3, static_register["two"]
    assert_nil static_register[false]
    assert_nil static_register["unknown"]
  end

  def test_delete
    static_register = set

    assert_equal true, static_register.delete(nil)
    assert_equal :one, static_register.delete(1)
    assert_equal "one", static_register.delete(:one)
    assert_equal 3, static_register.delete("two")
    assert_nil static_register.delete(false)
    assert_nil static_register.delete("unknown")

    assert_equal({}, static_register.registers)
  end

  def test_fetch
    static_register = set

    assert_equal true, static_register.fetch(nil)
    assert_equal :one, static_register.fetch(1)
    assert_equal "one", static_register.fetch(:one)
    assert_equal 3, static_register.fetch("two")
    assert_nil static_register.fetch(false)
    assert_nil static_register.fetch("unknown")
  end

  def test_fetch_default
    static_register = StaticRegisters.new

    assert_equal true, static_register.fetch(nil, true)
    assert_equal :one, static_register.fetch(1, :one)
    assert_equal "one", static_register.fetch(:one, "one")
    assert_equal 3, static_register.fetch("two", 3)
    assert_nil static_register.fetch(false, nil)
  end

  def test_key
    static_register = set

    assert_equal true, static_register.key?(nil)
    assert_equal true, static_register.key?(1)
    assert_equal true, static_register.key?(:one)
    assert_equal true, static_register.key?("two")
    assert_equal true, static_register.key?(false)
    assert_equal false, static_register.key?("unknown")
    assert_equal false, static_register.key?(true)
  end

  def set_with_static
    static_register = StaticRegisters.new(nil => true, 1 => :one, :one => "one", "two" => 3, false => nil)
    static_register[nil] = false
    static_register["two"] = 4
    static_register[true] = "foo"

    assert_equal({ nil => true, 1 => :one, :one => "one", "two" => 3, false => nil }, static_register.static_registers)
    assert_equal({ nil => false, "two" => 4, true => "foo" }, static_register.registers)

    static_register
  end

  def test_get_with_static
    static_register = set_with_static

    assert_equal false, static_register[nil]
    assert_equal :one, static_register[1]
    assert_equal "one", static_register[:one]
    assert_equal 4, static_register["two"]
    assert_equal "foo", static_register[true]
    assert_nil static_register[false]
  end

  def test_delete_with_static
    static_register = set_with_static

    assert_equal false, static_register.delete(nil)
    assert_equal 4, static_register.delete("two")
    assert_equal "foo", static_register.delete(true)
    assert_nil static_register.delete("unknown")
    assert_nil static_register.delete(:one)

    assert_equal({}, static_register.registers)
    assert_equal({ nil => true, 1 => :one, :one => "one", "two" => 3, false => nil }, static_register.static_registers)
  end

  def test_fetch_with_static
    static_register = set_with_static

    assert_equal false, static_register.fetch(nil)
    assert_equal :one, static_register.fetch(1)
    assert_equal "one", static_register.fetch(:one)
    assert_equal 4, static_register.fetch("two")
    assert_equal "foo", static_register.fetch(true)
    assert_nil static_register.fetch(false)
  end

  def test_key_with_static
    static_register = set_with_static

    assert_equal true, static_register.key?(nil)
    assert_equal true, static_register.key?(1)
    assert_equal true, static_register.key?(:one)
    assert_equal true, static_register.key?("two")
    assert_equal true, static_register.key?(false)
    assert_equal false, static_register.key?("unknown")
    assert_equal true, static_register.key?(true)
  end

  def test_static_register_frozen
    static_register = set_with_static

    static = static_register.static_registers

    assert_raises(FrozenError) do
      static["two"] = "foo"
    end

    assert_raises(FrozenError) do
      static["unknown"] = "foo"
    end

    assert_raises(FrozenError) do
      static.delete("two")
    end
  end
end
