# frozen_string_literal: true

require 'test_helper'

# Tests that the fast-path parser (try_fast_parse) produces the same result as the
# full Lexer → Parser pipeline for every input we expect it to handle.
#
# This protects against silent regressions where a change to try_fast_parse causes it
# to produce different output from the slow path (the existing test suite would still
# pass because the slow path catches it, but correctness would be silently lost).
class VariableFastParseTest < Minitest::Test
  include Liquid

  EQUIVALENCE_CASES = [
    # Simple lookups
    "product",
    "product.title",
    "product.variants.first.title",
    # Quoted string literals
    "'hello'",
    '"hello"',
    # Variables with no-arg filters
    "product | upcase",
    "product | upcase | downcase",
    "product | strip | upcase | downcase",
    # Variables with single-arg filters
    "product | truncate: 50",
    "product | plus: 1",
    "product | plus: -3",
    "product | round: 2",
    "product | append: ' world'",
    # Variables with multi-arg filters
    "product | replace: 'a', 'b'",
    "product | pluralize: 'item', 'items'",
    "product | slice: 0, 5",
    # Chained mixed filters
    "product.title | truncate: 50",
    "'hello' | append: ' world' | upcase",
    "name | prepend: 'Dr. ' | append: ' PhD' | upcase",
    # Numeric args
    "count | plus: 1.5",
    "price | minus: 0.99",
    # No whitespace around pipe
    "x|upcase",
    "x|replace:'a','b'|upcase",
    # Leading/trailing whitespace
    "  product  ",
    "  product.title | upcase  ",
  ].freeze

  EQUIVALENCE_CASES.each_with_index do |markup, i|
    define_method(:"test_fast_parse_equivalence_#{i.to_s.rjust(2, "0")}") do
      lax_ctx    = Liquid::ParseContext.new(error_mode: :lax)
      strict_ctx = Liquid::ParseContext.new(error_mode: :strict)

      lax_var    = Liquid::Variable.new(markup, lax_ctx)
      strict_var = Liquid::Variable.new(markup, strict_ctx)

      assert_equal strict_var.name,
        lax_var.name,
        "Name mismatch for #{markup.inspect}: " \
          "lax=#{lax_var.name.inspect} strict=#{strict_var.name.inspect}"
      assert_equal strict_var.filters.length,
        lax_var.filters.length,
        "Filter count mismatch for #{markup.inspect}: " \
          "lax=#{lax_var.filters.inspect} strict=#{strict_var.filters.inspect}"
      strict_var.filters.each_with_index do |(s_name, *), i|
        l_name = lax_var.filters[i][0]
        assert_equal s_name,
          l_name,
          "Filter name mismatch at index #{i} for #{markup.inspect}"
      end
    end
  end

  # Verify the fast path is actually taken for simple variables (i.e. filters is the
  # shared frozen EMPTY_ARRAY, not a newly allocated array).
  def test_fast_path_taken_for_simple_variable
    ctx = Liquid::ParseContext.new(error_mode: :lax)
    var = Liquid::Variable.new("product.title", ctx)
    assert_same(
      Liquid::Const::EMPTY_ARRAY,
      var.filters,
      "Expected fast path (frozen EMPTY_ARRAY) for simple variable",
    )
  end

  def test_fast_path_taken_for_no_arg_filter
    ctx = Liquid::ParseContext.new(error_mode: :lax)
    var = Liquid::Variable.new("product | upcase", ctx)
    assert_equal(1, var.filters.length)
    assert_equal("upcase", var.filters[0][0])
    # The no-arg filter tuple should come from NO_ARG_FILTER_CACHE (frozen)
    assert_predicate(var.filters[0], :frozen?)
  end

  def test_fast_path_taken_for_single_arg_filter
    ctx = Liquid::ParseContext.new(error_mode: :lax)
    var = Liquid::Variable.new("product | truncate: 50", ctx)
    assert_equal(1, var.filters.length)
    assert_equal("truncate", var.filters[0][0])
    assert_equal([50], var.filters[0][1])
  end

  # Keyword args must fall through to the Lexer — verify the result is still correct.
  def test_keyword_arg_falls_to_lexer_and_parses_correctly
    ctx = Liquid::ParseContext.new(error_mode: :lax)
    var = Liquid::Variable.new("img | img_tag: class: 'hero'", ctx)
    assert_equal(1, var.filters.length)
    assert_equal("img_tag", var.filters[0][0])
  end

  # Numeric filter arguments: integers and floats
  def test_numeric_filter_args
    ctx = Liquid::ParseContext.new(error_mode: :lax)

    int_var = Liquid::Variable.new("price | plus: 3", ctx)
    assert_equal([3], int_var.filters[0][1])

    neg_var = Liquid::Variable.new("price | minus: -1", ctx)
    assert_equal([-1], neg_var.filters[0][1])

    float_var = Liquid::Variable.new("price | round: 2.5", ctx)
    assert_equal([2.5], float_var.filters[0][1])
  end
end
