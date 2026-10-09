# frozen_string_literal: true

require 'test_helper'

class EnvironmentFilterTest < Minitest::Test
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

  module LateAddedFilter
    def late_added_filter(_input)
      "filtered"
    end
  end

  def setup
    @environment = Liquid::Environment.build do |env|
      env.register_filter(AccessScopeFilters)
    end

    @context = Context.build(environment: @environment)
  end

  def test_strainer
    strainer = @environment.create_strainer(@context)
    assert_equal(5, strainer.invoke('size', 'input'))
    assert_equal("public", strainer.invoke("public_filter"))
  end

  def test_strainer_raises_argument_error
    strainer = @environment.create_strainer(@context)
    assert_raises(Liquid::ArgumentError) do
      strainer.invoke("public_filter", 1)
    end
  end

  def test_strainer_argument_error_contains_backtrace
    strainer = @environment.create_strainer(@context)

    exception = assert_raises(Liquid::ArgumentError) do
      strainer.invoke("public_filter", 1)
    end

    assert_match(
      /\ALiquid error: wrong number of arguments \((1 for 0|given 1, expected 0)\)\z/,
      exception.message,
    )

    source = AccessScopeFilters.instance_method(:public_filter).source_location
    assert_equal(source[0..1].map(&:to_s), exception.backtrace[0].split(':')[0..1])
  end

  def test_strainer_only_invokes_public_filter_methods
    strainer = @environment.create_strainer(@context)
    assert_equal(false, strainer.class.invokable?('__test__'))
    assert_equal(false, strainer.class.invokable?('test'))
    assert_equal(false, strainer.class.invokable?('instance_eval'))
    assert_equal(false, strainer.class.invokable?('__send__'))
    assert_equal(true, strainer.class.invokable?('size')) # from the standard lib
  end

  def test_strainer_returns_nil_if_no_filter_method_found
    strainer = @environment.create_strainer(@context)
    assert_nil(strainer.invoke("private_filter"))
    assert_nil(strainer.invoke("undef_the_filter"))
  end

  def test_strainer_returns_first_argument_if_no_method_and_arguments_given
    strainer = @environment.create_strainer(@context)
    assert_equal("password", strainer.invoke("undef_the_method", "password"))
  end

  def test_strainer_only_allows_methods_defined_in_filters
    strainer = @environment.create_strainer(@context)
    assert_equal("1 + 1", strainer.invoke("instance_eval", "1 + 1"))
    assert_equal("puts",  strainer.invoke("__send__", "puts", "Hi Mom"))
    assert_equal("has_method?", strainer.invoke("invoke", "has_method?", "invoke"))
  end

  def test_strainer_uses_a_class_cache_to_avoid_method_cache_invalidation
    a = Module.new
    b = Module.new

    strainer = @environment.create_strainer(@context, [a, b])

    assert_kind_of(StrainerTemplate, strainer)
    assert_kind_of(a, strainer)
    assert_kind_of(b, strainer)
    assert_kind_of(Liquid::StandardFilters, strainer)
  end

  def test_add_global_filter_clears_cache
    assert_equal('input', @environment.create_strainer(@context).invoke('late_added_filter', 'input'))

    @environment.register_filter(LateAddedFilter)

    assert_equal('filtered', @environment.create_strainer(nil).invoke('late_added_filter', 'input'))
  end
end
