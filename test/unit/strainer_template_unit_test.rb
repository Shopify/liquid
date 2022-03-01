# frozen_string_literal: true

require 'test_helper'

class StrainerTemplateUnitTest < Minitest::Test
  include Liquid

  def test_add_filter_when_wrong_filter_class
    c = Context.new
    s = c.strainer
    wrong_filter = ->(v) { v.reverse }

    exception = assert_raises(TypeError) do
      s.class.add_filter(wrong_filter)
    end
    assert_equal(exception.message, "wrong argument type Proc (expected Module)")
  end

  module PrivateMethodOverrideFilter
    private

    def public_filter
      "overriden as private"
    end
  end

  def test_add_filter_raises_when_module_privately_overrides_registered_public_methods
    strainer = Context.new.strainer

    error = assert_raises(Liquid::MethodOverrideError) do
      strainer.class.add_filter(PrivateMethodOverrideFilter)
    end
    assert_equal('Liquid error: Filter overrides registered public methods as non public: public_filter', error.message)
  end

  module ProtectedMethodOverrideFilter
    protected

    def public_filter
      "overriden as protected"
    end
  end

  def test_add_filter_raises_when_module_overrides_registered_public_method_as_protected
    strainer = Context.new.strainer

    error = assert_raises(Liquid::MethodOverrideError) do
      strainer.class.add_filter(ProtectedMethodOverrideFilter)
    end
    assert_equal('Liquid error: Filter overrides registered public methods as non public: public_filter', error.message)
  end

  module PublicMethodOverrideFilter
    def public_filter
      "public"
    end
  end

  def test_add_filter_does_not_raise_when_module_overrides_previously_registered_method
    with_global_filter do
      strainer = Context.new.strainer
      strainer.class.add_filter(PublicMethodOverrideFilter)
      assert(strainer.class.send(:filter_methods).include?('public_filter'))
    end
  end

  def test_add_filter_does_not_include_already_included_module
    mod = Module.new do
      class << self
        attr_accessor :include_count
        def included(_mod)
          self.include_count += 1
        end
      end
      self.include_count = 0
    end
    strainer = Context.new.strainer
    strainer.class.add_filter(mod)
    strainer.class.add_filter(mod)
    assert_equal(1, mod.include_count)
  end
end
