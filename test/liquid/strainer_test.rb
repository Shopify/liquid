require 'test_helper'

class StrainerTest < Test::Unit::TestCase
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

  def test_strainer_only_invokes_public_filter_methods
    strainer = Strainer.create(nil)
    assert_equal false, strainer.invokable?('__test__')
    assert_equal false, strainer.invokable?('test')
    assert_equal false, strainer.invokable?('instance_eval')
    assert_equal false, strainer.invokable?('__send__')
    assert_equal true, strainer.invokable?('size') # from the standard lib
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

end # StrainerTest
