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

class TestClassD
  liquid_methods :allowedD, :chainedE do |object, method, value|
    if value.is_a?(String)
      value += "andtransformedD"
    else
      value
    end
  end

  def allowedD
    'allowedD'
  end
  def restrictedD
    'restrictedD'
  end
  def chainedE
    TestClassE.new
  end
end

class TestClassE
  liquid_methods :allowedE do |object, method, value|
    if value.is_a?(String)
      value += "andtransformedE"
    else
      value
    end
  end
  def allowedE
    'allowedE'
  end
end

class ModuleExUnitTest < Minitest::Test
  include Liquid

  def setup
    @a = TestClassA.new
    @b = TestClassB.new
    @c = TestClassC.new
    @d = TestClassD.new
    @e = TestClassE.new
  end

  def test_should_create_LiquidDropClass
    assert TestClassA::LiquidDropClass
    assert TestClassB::LiquidDropClass
    assert TestClassC::LiquidDropClass
    assert TestClassD::LiquidDropClass
    assert TestClassE::LiquidDropClass
  end

  def test_should_respond_to_liquid
    assert @a.respond_to?(:to_liquid)
    assert @b.respond_to?(:to_liquid)
    assert @c.respond_to?(:to_liquid)
    assert @d.respond_to?(:to_liquid)
    assert @e.respond_to?(:to_liquid)
  end

  def test_should_return_LiquidDropClass_object
    assert @a.to_liquid.is_a?(TestClassA::LiquidDropClass)
    assert @b.to_liquid.is_a?(TestClassB::LiquidDropClass)
    assert @c.to_liquid.is_a?(TestClassC::LiquidDropClass)
    assert @d.to_liquid.is_a?(TestClassD::LiquidDropClass)
    assert @e.to_liquid.is_a?(TestClassE::LiquidDropClass)
  end

  def test_should_respond_to_liquid_methods
    assert @a.to_liquid.respond_to?(:allowedA)
    assert @a.to_liquid.respond_to?(:chainedB)
    assert @b.to_liquid.respond_to?(:allowedB)
    assert @b.to_liquid.respond_to?(:chainedC)
    assert @c.to_liquid.respond_to?(:allowedC)
    assert @c.to_liquid.respond_to?(:another_allowedC)
    assert @d.to_liquid.respond_to?(:allowedD)
    assert @d.to_liquid.respond_to?(:chainedE)
    assert @e.to_liquid.respond_to?(:allowedE)
  end

  def test_should_not_respond_to_restricted_methods
    assert ! @a.to_liquid.respond_to?(:restrictedA)
    assert ! @d.to_liquid.respond_to?(:restrictedD)
  end

  def test_should_use_regular_objects_as_drops
    assert_template_result 'allowedA', "{{ a.allowedA }}", 'a'=>@a
    assert_template_result 'allowedB', "{{ a.chainedB.allowedB }}", 'a'=>@a
    assert_template_result 'allowedC', "{{ a.chainedB.chainedC.allowedC }}", 'a'=>@a
    assert_template_result 'another_allowedC', "{{ a.chainedB.chainedC.another_allowedC }}", 'a'=>@a
    assert_template_result '', "{{ a.restricted }}", 'a'=>@a
    assert_template_result '', "{{ a.unknown }}", 'a'=>@a
  end

  def test_that_block_succesfully_transforms_object_methods
    assert_template_result 'allowedDandtransformedD', "{{ d.allowedD }}", 'd'=>@d
    assert_template_result 'allowedEandtransformedE', "{{ d.chainedE.allowedE }}", 'd'=>@d
  end
end # ModuleExTest
