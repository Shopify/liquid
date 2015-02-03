require 'test_helper'

class StrainerUnitTest < Minitest::Test
  include Liquid

  module AccessScopeFilters
    def public_filter
      "public"
    end

    def private_filter
      "private"
    end
    private :private_filter
  end

  Strainer.global_filter(AccessScopeFilters)

  def test_strainer
    strainer = Strainer.create(nil)
    assert_equal 5, strainer.invoke('size', 'input')
    assert_equal "public", strainer.invoke("public_filter")
  end

  def test_stainer_raises_argument_error
    strainer = Strainer.create(nil)
    assert_raises(Liquid::ArgumentError) do
      strainer.invoke("public_filter", 1)
    end
  end

  def test_strainer_only_invokes_public_filter_methods
    strainer = Strainer.create(nil)
    assert_equal false, strainer.class.invokable?('__test__')
    assert_equal false, strainer.class.invokable?('test')
    assert_equal false, strainer.class.invokable?('instance_eval')
    assert_equal false, strainer.class.invokable?('__send__')
    assert_equal true, strainer.class.invokable?('size') # from the standard lib
  end

  def test_strainer_returns_nil_if_no_filter_method_found
    strainer = Strainer.create(nil)
    assert_nil strainer.invoke("private_filter")
    assert_nil strainer.invoke("undef_the_filter")
  end

  def test_strainer_returns_first_argument_if_no_method_and_arguments_given
    strainer = Strainer.create(nil)
    assert_equal "password", strainer.invoke("undef_the_method", "password")
  end

  def test_strainer_only_allows_methods_defined_in_filters
    strainer = Strainer.create(nil)
    assert_equal "1 + 1", strainer.invoke("instance_eval", "1 + 1")
    assert_equal "puts",  strainer.invoke("__send__", "puts", "Hi Mom")
    assert_equal "has_method?", strainer.invoke("invoke", "has_method?", "invoke")
  end

  def test_strainer_uses_a_class_cache_to_avoid_method_cache_invalidation
    a = Module.new
    b = Module.new
    strainer = Strainer.create(nil, [a,b])
    assert_kind_of Strainer, strainer
    assert_kind_of a, strainer
    assert_kind_of b, strainer
    assert_kind_of Liquid::StandardFilters, strainer
  end

end # StrainerTest
