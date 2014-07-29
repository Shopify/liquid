require 'test_helper'

class TestClassA
  liquid_methods :allowedA, :chainedB
  def allowedA
    'allowedA'
  end
  def restrictedA
    'restrictedA'
  end
  def chainedB
    TestClassB.new
  end
end

class TestClassB
  liquid_methods :allowedB, :chainedC
  def allowedB
    'allowedB'
  end
  def chainedC
    TestClassC.new
  end
end

class TestClassC
  liquid_methods :allowedC
  def allowedC
    'allowedC'
  end
end

class TestClassC::LiquidDropClass
  def another_allowedC
    'another_allowedC'
  end
end

class ModuleExUnitTest < Minitest::Test
  include Liquid

  def setup
    @a = TestClassA.new
    @b = TestClassB.new
    @c = TestClassC.new
  end

  def test_should_create_LiquidDropClass
    assert TestClassA::LiquidDropClass
    assert TestClassB::LiquidDropClass
    assert TestClassC::LiquidDropClass
  end

  def test_should_respond_to_liquid
    assert @a.respond_to?(:to_liquid)
    assert @b.respond_to?(:to_liquid)
    assert @c.respond_to?(:to_liquid)
  end

  def test_should_return_LiquidDropClass_object
    assert @a.to_liquid.is_a?(TestClassA::LiquidDropClass)
    assert @b.to_liquid.is_a?(TestClassB::LiquidDropClass)
    assert @c.to_liquid.is_a?(TestClassC::LiquidDropClass)
  end

  def test_should_respond_to_liquid_methods
    assert @a.to_liquid.respond_to?(:allowedA)
    assert @a.to_liquid.respond_to?(:chainedB)
    assert @b.to_liquid.respond_to?(:allowedB)
    assert @b.to_liquid.respond_to?(:chainedC)
    assert @c.to_liquid.respond_to?(:allowedC)
    assert @c.to_liquid.respond_to?(:another_allowedC)
  end

  def test_should_not_respond_to_restricted_methods
    assert ! @a.to_liquid.respond_to?(:restricted)
  end

  def test_should_use_regular_objects_as_drops
    assert_template_result 'allowedA', "{{ a.allowedA }}", 'a'=>@a
    assert_template_result 'allowedB', "{{ a.chainedB.allowedB }}", 'a'=>@a
    assert_template_result 'allowedC', "{{ a.chainedB.chainedC.allowedC }}", 'a'=>@a
    assert_template_result 'another_allowedC', "{{ a.chainedB.chainedC.another_allowedC }}", 'a'=>@a
    assert_template_result '', "{{ a.restricted }}", 'a'=>@a
    assert_template_result '', "{{ a.unknown }}", 'a'=>@a
  end
end # ModuleExTest
