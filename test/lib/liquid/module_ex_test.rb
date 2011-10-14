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
  liquid_methods :allowedD, :reverse_context => :context
  def allowedD
    'allowedD'
  end
end

class ModuleExTest < Test::Unit::TestCase
  include Liquid

  def setup
    @a = TestClassA.new
    @b = TestClassB.new
    @c = TestClassC.new
    @d = TestClassD.new
  end

  def test_should_create_LiquidDropClass
    assert TestClassA::LiquidDropClass
    assert TestClassB::LiquidDropClass
    assert TestClassC::LiquidDropClass
    assert TestClassD::LiquidDropClass
  end

  def test_should_respond_to_liquid
    assert @a.respond_to?(:to_liquid)
    assert @b.respond_to?(:to_liquid)
    assert @c.respond_to?(:to_liquid)
    assert @d.respond_to?(:to_liquid)
  end

  def test_should_return_LiquidDropClass_object
    assert @a.to_liquid.is_a?(TestClassA::LiquidDropClass)
    assert @b.to_liquid.is_a?(TestClassB::LiquidDropClass)
    assert @c.to_liquid.is_a?(TestClassC::LiquidDropClass)
    assert @d.to_liquid.is_a?(TestClassD::LiquidDropClass)
  end

  def test_should_respond_to_liquid_methods
    assert @a.to_liquid.respond_to?(:allowedA)
    assert @a.to_liquid.respond_to?(:chainedB)
    assert @b.to_liquid.respond_to?(:allowedB)
    assert @b.to_liquid.respond_to?(:chainedC)
    assert @c.to_liquid.respond_to?(:allowedC)
    assert @c.to_liquid.respond_to?(:another_allowedC)
    assert @d.to_liquid.respond_to?(:allowedD)
  end

  def test_should_not_respond_to_restricted_methods
    assert ! @a.to_liquid.respond_to?(:restricted)
  end

  def test_should_use_regular_objects_as_drops
    assert_equal 'allowedA', Liquid::Template.parse("{{ a.allowedA }}").render('a'=>@a)
    assert_equal 'allowedB', Liquid::Template.parse("{{ a.chainedB.allowedB }}").render('a'=>@a)
    assert_equal 'allowedC', Liquid::Template.parse("{{ a.chainedB.chainedC.allowedC }}").render('a'=>@a)
    assert_equal 'another_allowedC', Liquid::Template.parse("{{ a.chainedB.chainedC.another_allowedC }}").render('a'=>@a)
    assert_equal '', Liquid::Template.parse("{{ a.restricted }}").render('a'=>@a)
    assert_equal '', Liquid::Template.parse("{{ a.unknown }}").render('a'=>@a)
  end

  def test_reverse_context
    assert_nil TestClassA.reverse_context_method
    assert_nil TestClassB.reverse_context_method
    assert_nil TestClassC.reverse_context_method

    assert_equal 'context', TestClassD.reverse_context_method
    assert @d.respond_to?(:context)
    d_drop = @d.to_liquid
    d_drop.context = (d_context = Liquid::Context.new)
    assert_same d_drop, @d.instance_variable_get('@liquid_drop')
    assert_same d_context, @d.context
  end
end # ModuleExTest
