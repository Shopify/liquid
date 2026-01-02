# frozen_string_literal: true

require 'test_helper'

class ConditionUnitTest < Minitest::Test
  include Liquid

  def setup
    @context = Liquid::Context.new
  end

  def test_basic_condition
    assert_equal(false, Condition.new(1, '==', 2).evaluate(Context.new))
    assert_equal(true,  Condition.new(1, '==', 1).evaluate(Context.new))
  end

  def test_default_operators_evalute_true
    assert_evaluates_true(1, '==', 1)
    assert_evaluates_true(1, '!=', 2)
    assert_evaluates_true(1, '<>', 2)
    assert_evaluates_true(1, '<', 2)
    assert_evaluates_true(2, '>', 1)
    assert_evaluates_true(1, '>=', 1)
    assert_evaluates_true(2, '>=', 1)
    assert_evaluates_true(1, '<=', 2)
    assert_evaluates_true(1, '<=', 1)
    # negative numbers
    assert_evaluates_true(1, '>', -1)
    assert_evaluates_true(-1, '<', 1)
    assert_evaluates_true(1.0, '>', -1.0)
    assert_evaluates_true(-1.0, '<', 1.0)
  end

  def test_default_operators_evalute_false
    assert_evaluates_false(1, '==', 2)
    assert_evaluates_false(1, '!=', 1)
    assert_evaluates_false(1, '<>', 1)
    assert_evaluates_false(1, '<', 0)
    assert_evaluates_false(2, '>', 4)
    assert_evaluates_false(1, '>=', 3)
    assert_evaluates_false(2, '>=', 4)
    assert_evaluates_false(1, '<=', 0)
    assert_evaluates_false(1, '<=', 0)
  end

  def test_contains_works_on_strings
    assert_evaluates_true('bob', 'contains', 'o')
    assert_evaluates_true('bob', 'contains', 'b')
    assert_evaluates_true('bob', 'contains', 'bo')
    assert_evaluates_true('bob', 'contains', 'ob')
    assert_evaluates_true('bob', 'contains', 'bob')

    assert_evaluates_false('bob', 'contains', 'bob2')
    assert_evaluates_false('bob', 'contains', 'a')
    assert_evaluates_false('bob', 'contains', '---')
  end

  def test_contains_binary_encoding_compatibility_with_utf8
    assert_evaluates_true('🙈'.b, 'contains', '🙈')
    assert_evaluates_true('🙈', 'contains', '🙈'.b)
  end

  def test_invalid_comparation_operator
    assert_evaluates_argument_error(1, '~~', 0)
  end

  def test_comparation_of_int_and_str
    assert_evaluates_argument_error('1', '>', 0)
    assert_evaluates_argument_error('1', '<', 0)
    assert_evaluates_argument_error('1', '>=', 0)
    assert_evaluates_argument_error('1', '<=', 0)
  end

  def test_hash_compare_backwards_compatibility
    assert_nil(Condition.new({}, '>', 2).evaluate(Context.new))
    assert_nil(Condition.new(2, '>', {}).evaluate(Context.new))
    assert_equal(false, Condition.new({}, '==', 2).evaluate(Context.new))
    assert_equal(true, Condition.new({ 'a' => 1 }, '==', 'a' => 1).evaluate(Context.new))
    assert_equal(true, Condition.new({ 'a' => 2 }, 'contains', 'a').evaluate(Context.new))
  end

  def test_contains_works_on_arrays
    @context          = Liquid::Context.new
    @context['array'] = [1, 2, 3, 4, 5]
    array_expr        = VariableLookup.new("array")

    assert_evaluates_false(array_expr, 'contains', 0)
    assert_evaluates_true(array_expr, 'contains', 1)
    assert_evaluates_true(array_expr, 'contains', 2)
    assert_evaluates_true(array_expr, 'contains', 3)
    assert_evaluates_true(array_expr, 'contains', 4)
    assert_evaluates_true(array_expr, 'contains', 5)
    assert_evaluates_false(array_expr, 'contains', 6)
    assert_evaluates_false(array_expr, 'contains', "1")
  end

  def test_contains_returns_false_for_nil_operands
    @context = Liquid::Context.new
    assert_evaluates_false(VariableLookup.new('not_assigned'), 'contains', '0')
    assert_evaluates_false(0, 'contains', VariableLookup.new('not_assigned'))
  end

  def test_contains_return_false_on_wrong_data_type
    assert_evaluates_false(1, 'contains', 0)
  end

  def test_contains_with_string_left_operand_coerces_right_operand_to_string
    assert_evaluates_true(' 1 ', 'contains', 1)
    assert_evaluates_false(' 1 ', 'contains', 2)
  end

  def test_or_condition
    condition = Condition.new(1, '==', 2)
    assert_equal(false, condition.evaluate(Context.new))

    condition.or(Condition.new(2, '==', 1))

    assert_equal(false, condition.evaluate(Context.new))

    condition.or(Condition.new(1, '==', 1))

    assert_equal(true, condition.evaluate(Context.new))
  end

  def test_and_condition
    condition = Condition.new(1, '==', 1)

    assert_equal(true, condition.evaluate(Context.new))

    condition.and(Condition.new(2, '==', 2))

    assert_equal(true, condition.evaluate(Context.new))

    condition.and(Condition.new(2, '==', 1))

    assert_equal(false, condition.evaluate(Context.new))
  end

  def test_should_allow_custom_proc_operator
    Condition.operators['starts_with'] = proc { |_cond, left, right| left =~ /^#{right}/ }

    assert_evaluates_true('bob', 'starts_with', 'b')
    assert_evaluates_false('bob', 'starts_with', 'o')
  ensure
    Condition.operators.delete('starts_with')
  end

  def test_left_or_right_may_contain_operators
    @context        = Liquid::Context.new
    @context['one'] = @context['another'] = "gnomeslab-and-or-liquid"

    assert_evaluates_true(VariableLookup.new("one"), '==', VariableLookup.new("another"))
  end

  def test_default_context_is_deprecated
    if Gem::Version.new(Liquid::VERSION) >= Gem::Version.new('6.0.0')
      flunk("Condition#evaluate without a context argument is to be removed")
    end

    _out, err = capture_io do
      assert_equal(true, Condition.new(1, '==', 1).evaluate)
    end

    expected = "DEPRECATION WARNING: Condition#evaluate without a context argument is deprecated " \
      "and will be removed from Liquid 6.0.0."
    assert_includes(err.lines.map(&:strip), expected)
  end

  def test_parse_expression_in_strict_mode
    environment = Environment.build(error_mode: :strict)
    parse_context = ParseContext.new(environment: environment)
    result = Condition.parse_expression(parse_context, 'product.title')

    assert_instance_of(VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal(['title'], result.lookups)
  end

  def test_parse_expression_in_strict2_mode_raises_internal_error
    environment = Environment.build(error_mode: :strict2)
    parse_context = ParseContext.new(environment: environment)

    error = assert_raises(Liquid::InternalError) do
      Condition.parse_expression(parse_context, 'product.title')
    end

    assert_match(/unsafe parse_expression cannot be used in strict2 mode/, error.message)
  end

  def test_parse_expression_with_safe_true_in_strict2_mode
    environment = Environment.build(error_mode: :strict2)
    parse_context = ParseContext.new(environment: environment)
    result = Condition.parse_expression(parse_context, 'product.title', safe: true)

    assert_instance_of(VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal(['title'], result.lookups)
  end

  # Tests for blank? comparison without ActiveSupport
  #
  # Ruby's standard library does not include blank? on String, Array, Hash, etc.
  # ActiveSupport adds blank? but Liquid must work without it. These tests verify
  # that Liquid implements blank? semantics internally for use in templates like:
  #   {% if x == blank %}...{% endif %}
  #
  # The blank? semantics match ActiveSupport's behavior:
  # - nil and false are blank
  # - Strings are blank if empty or contain only whitespace
  # - Arrays and Hashes are blank if empty
  # - true and numbers are never blank

  def test_blank_with_whitespace_string
    # Template authors expect "   " to be blank since it has no visible content.
    # This matches ActiveSupport's String#blank? which returns true for whitespace-only strings.
    @context['whitespace'] = '   '
    blank_literal = Condition.class_variable_get(:@@method_literals)['blank']

    assert_evaluates_true(VariableLookup.new('whitespace'), '==', blank_literal)
  end

  def test_blank_with_empty_string
    # An empty string has no content, so it should be considered blank.
    # This is the most basic case of a blank string.
    @context['empty_string'] = ''
    blank_literal = Condition.class_variable_get(:@@method_literals)['blank']

    assert_evaluates_true(VariableLookup.new('empty_string'), '==', blank_literal)
  end

  def test_blank_with_empty_array
    # Empty arrays have no elements, so they are blank.
    # Useful for checking if a collection has items: {% if products == blank %}
    @context['empty_array'] = []
    blank_literal = Condition.class_variable_get(:@@method_literals)['blank']

    assert_evaluates_true(VariableLookup.new('empty_array'), '==', blank_literal)
  end

  def test_blank_with_empty_hash
    # Empty hashes have no key-value pairs, so they are blank.
    # Useful for checking if settings/options exist: {% if settings == blank %}
    @context['empty_hash'] = {}
    blank_literal = Condition.class_variable_get(:@@method_literals)['blank']

    assert_evaluates_true(VariableLookup.new('empty_hash'), '==', blank_literal)
  end

  def test_blank_with_nil
    # nil represents "nothing" and is the canonical blank value.
    # Unassigned variables resolve to nil, so this enables: {% if missing_var == blank %}
    @context['nil_value'] = nil
    blank_literal = Condition.class_variable_get(:@@method_literals)['blank']

    assert_evaluates_true(VariableLookup.new('nil_value'), '==', blank_literal)
  end

  def test_blank_with_false
    # false is considered blank to match ActiveSupport semantics.
    # This allows {% if some_flag == blank %} to work when flag is false.
    @context['false_value'] = false
    blank_literal = Condition.class_variable_get(:@@method_literals)['blank']

    assert_evaluates_true(VariableLookup.new('false_value'), '==', blank_literal)
  end

  def test_not_blank_with_true
    # true is a definite value, not blank.
    # Ensures {% if flag == blank %} works correctly for boolean flags.
    @context['true_value'] = true
    blank_literal = Condition.class_variable_get(:@@method_literals)['blank']

    assert_evaluates_false(VariableLookup.new('true_value'), '==', blank_literal)
  end

  def test_not_blank_with_number
    # Numbers (including zero) are never blank - they represent actual values.
    # 0 is a valid quantity, not the absence of a value.
    @context['number'] = 42
    blank_literal = Condition.class_variable_get(:@@method_literals)['blank']

    assert_evaluates_false(VariableLookup.new('number'), '==', blank_literal)
  end

  def test_not_blank_with_string_content
    # A string with actual content is not blank.
    # This is the expected behavior for most template string comparisons.
    @context['string'] = 'hello'
    blank_literal = Condition.class_variable_get(:@@method_literals)['blank']

    assert_evaluates_false(VariableLookup.new('string'), '==', blank_literal)
  end

  def test_not_blank_with_non_empty_array
    # An array with elements has content, so it's not blank.
    # Enables patterns like {% unless products == blank %}Show products{% endunless %}
    @context['array'] = [1, 2, 3]
    blank_literal = Condition.class_variable_get(:@@method_literals)['blank']

    assert_evaluates_false(VariableLookup.new('array'), '==', blank_literal)
  end

  def test_not_blank_with_non_empty_hash
    # A hash with key-value pairs has content, so it's not blank.
    # Useful for checking if configuration exists: {% if config != blank %}
    @context['hash'] = { 'a' => 1 }
    blank_literal = Condition.class_variable_get(:@@method_literals)['blank']

    assert_evaluates_false(VariableLookup.new('hash'), '==', blank_literal)
  end

  # Tests for empty? comparison without ActiveSupport
  #
  # empty? is distinct from blank? - it only checks if a collection has zero elements.
  # For strings, empty? checks length == 0, NOT whitespace content.
  # Ruby's standard library has empty? on String, Array, and Hash, but Liquid
  # provides a fallback implementation for consistency.

  def test_empty_with_empty_string
    # An empty string ("") has length 0, so it's empty.
    # Different from blank - empty is a stricter check.
    @context['empty_string'] = ''
    empty_literal = Condition.class_variable_get(:@@method_literals)['empty']

    assert_evaluates_true(VariableLookup.new('empty_string'), '==', empty_literal)
  end

  def test_empty_with_whitespace_string_not_empty
    # Whitespace strings have length > 0, so they are NOT empty.
    # This is the key difference between empty and blank:
    # "   ".empty? => false, but "   ".blank? => true
    @context['whitespace'] = '   '
    empty_literal = Condition.class_variable_get(:@@method_literals)['empty']

    assert_evaluates_false(VariableLookup.new('whitespace'), '==', empty_literal)
  end

  def test_empty_with_empty_array
    # An array with no elements is empty.
    # [].empty? => true
    @context['empty_array'] = []
    empty_literal = Condition.class_variable_get(:@@method_literals)['empty']

    assert_evaluates_true(VariableLookup.new('empty_array'), '==', empty_literal)
  end

  def test_empty_with_empty_hash
    # A hash with no key-value pairs is empty.
    # {}.empty? => true
    @context['empty_hash'] = {}
    empty_literal = Condition.class_variable_get(:@@method_literals)['empty']

    assert_evaluates_true(VariableLookup.new('empty_hash'), '==', empty_literal)
  end

  def test_nil_is_not_empty
    # nil is NOT empty - empty? checks if a collection has zero elements.
    # nil is not a collection, so it cannot be empty.
    # This differs from blank: nil IS blank, but nil is NOT empty.
    @context['nil_value'] = nil
    empty_literal = Condition.class_variable_get(:@@method_literals)['empty']

    assert_evaluates_false(VariableLookup.new('nil_value'), '==', empty_literal)
  end

  private

  def assert_evaluates_true(left, op, right)
    assert(
      Condition.new(left, op, right).evaluate(@context),
      "Evaluated false: #{left.inspect} #{op} #{right.inspect}",
    )
  end

  def assert_evaluates_false(left, op, right)
    assert(
      !Condition.new(left, op, right).evaluate(@context),
      "Evaluated true: #{left.inspect} #{op} #{right.inspect}",
    )
  end

  def assert_evaluates_argument_error(left, op, right)
    assert_raises(Liquid::ArgumentError) do
      Condition.new(left, op, right).evaluate(@context)
    end
  end
end # ConditionTest
