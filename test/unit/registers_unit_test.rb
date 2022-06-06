# frozen_string_literal: true

require 'test_helper'

class RegistersUnitTest < Minitest::Test
  include Liquid

  def test_set
    static_register = Registers.new(a: 1, b: 2)
    static_register[:b] = 22
    static_register[:c] = 33

    assert_equal(1, static_register[:a])
    assert_equal(22, static_register[:b])
    assert_equal(33, static_register[:c])
  end

  def test_get_missing_key
    static_register = Registers.new

    assert_nil(static_register[:missing])
  end

  def test_delete
    static_register = Registers.new(a: 1, b: 2)
    static_register[:b] = 22
    static_register[:c] = 33

    assert_nil(static_register.delete(:a))

    assert_equal(22, static_register.delete(:b))

    assert_equal(33, static_register.delete(:c))
    assert_nil(static_register[:c])

    assert_nil(static_register.delete(:d))
  end

  def test_fetch
    static_register = Registers.new(a: 1, b: 2)
    static_register[:b] = 22
    static_register[:c] = 33

    assert_equal(1, static_register.fetch(:a))
    assert_equal(1, static_register.fetch(:a, "default"))
    assert_equal(22, static_register.fetch(:b))
    assert_equal(22, static_register.fetch(:b, "default"))
    assert_equal(33, static_register.fetch(:c))
    assert_equal(33, static_register.fetch(:c, "default"))

    assert_raises(KeyError) do
      static_register.fetch(:d)
    end
    assert_equal("default", static_register.fetch(:d, "default"))

    result = static_register.fetch(:d) { "default" }
    assert_equal("default", result)

    result = static_register.fetch(:d, "default 1") { "default 2" }
    assert_equal("default 2", result)
  end

  def test_key
    static_register = Registers.new(a: 1, b: 2)
    static_register[:b] = 22
    static_register[:c] = 33

    assert_equal(true, static_register.key?(:a))
    assert_equal(true, static_register.key?(:b))
    assert_equal(true, static_register.key?(:c))
    assert_equal(false, static_register.key?(:d))
  end

  def test_static_register_can_be_frozen
    static_register = Registers.new(a: 1)

    static_register.static.freeze

    assert_raises(RuntimeError) do
      static_register.static[:a] = "foo"
    end

    assert_raises(RuntimeError) do
      static_register.static[:b] = "foo"
    end

    assert_raises(RuntimeError) do
      static_register.static.delete(:a)
    end

    assert_raises(RuntimeError) do
      static_register.static.delete(:c)
    end
  end

  def test_new_static_retains_static
    static_register = Registers.new(a: 1, b: 2)
    static_register[:b] = 22
    static_register[:c] = 33

    new_static_register = Registers.new(static_register)
    new_static_register[:b] = 222

    newest_static_register = Registers.new(new_static_register)
    newest_static_register[:c] = 333

    assert_equal(1, static_register[:a])
    assert_equal(22, static_register[:b])
    assert_equal(33, static_register[:c])

    assert_equal(1, new_static_register[:a])
    assert_equal(222, new_static_register[:b])
    assert_nil(new_static_register[:c])

    assert_equal(1, newest_static_register[:a])
    assert_equal(2, newest_static_register[:b])
    assert_equal(333, newest_static_register[:c])
  end

  def test_multiple_instances_are_unique
    static_register_1 = Registers.new(a: 1, b: 2)
    static_register_1[:b] = 22
    static_register_1[:c] = 33

    static_register_2 = Registers.new(a: 10, b: 20)
    static_register_2[:b] = 220
    static_register_2[:c] = 330

    assert_equal({ a: 1, b: 2 }, static_register_1.static)
    assert_equal(1, static_register_1[:a])
    assert_equal(22, static_register_1[:b])
    assert_equal(33, static_register_1[:c])

    assert_equal({ a: 10, b: 20 }, static_register_2.static)
    assert_equal(10, static_register_2[:a])
    assert_equal(220, static_register_2[:b])
    assert_equal(330, static_register_2[:c])
  end

  def test_initialization_reused_static_same_memory_object
    static_register_1 = Registers.new(a: 1, b: 2)
    static_register_1[:b] = 22
    static_register_1[:c] = 33

    static_register_2 = Registers.new(static_register_1)

    assert_equal(1, static_register_2[:a])
    assert_equal(2, static_register_2[:b])
    assert_nil(static_register_2[:c])

    static_register_1.static[:b] = 222
    static_register_1.static[:c] = 333

    assert_same(static_register_1.static, static_register_2.static)
  end
end
