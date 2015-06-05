require 'test_helper'

class ConditionUnitTest < Minitest::Test
  include Liquid

  def test_basic_condition
    assert_equal false, Condition.new(1, '==', 2).evaluate
    assert_equal true,  Condition.new(1, '==', 1).evaluate
  end

  def test_default_operators_evalute_true
    assert_evalutes_true 1, '==', 1
    assert_evalutes_true 1, '!=', 2
    assert_evalutes_true 1, '<>', 2
    assert_evalutes_true 1, '<', 2
    assert_evalutes_true 2, '>', 1
    assert_evalutes_true 1, '>=', 1
    assert_evalutes_true 2, '>=', 1
    assert_evalutes_true 1, '<=', 2
    assert_evalutes_true 1, '<=', 1
    # negative numbers
    assert_evalutes_true 1, '>', -1
    assert_evalutes_true -1, '<', 1
    assert_evalutes_true 1.0, '>', -1.0
    assert_evalutes_true -1.0, '<', 1.0
  end

  def test_default_operators_evalute_false
    assert_evalutes_false 1, '==', 2
    assert_evalutes_false 1, '!=', 1
    assert_evalutes_false 1, '<>', 1
    assert_evalutes_false 1, '<', 0
    assert_evalutes_false 2, '>', 4
    assert_evalutes_false 1, '>=', 3
    assert_evalutes_false 2, '>=', 4
    assert_evalutes_false 1, '<=', 0
    assert_evalutes_false 1, '<=', 0
  end

  def test_contains_works_on_strings
    assert_evalutes_true 'bob', 'contains', 'o'
    assert_evalutes_true 'bob', 'contains', 'b'
    assert_evalutes_true 'bob', 'contains', 'bo'
    assert_evalutes_true 'bob', 'contains', 'ob'
    assert_evalutes_true 'bob', 'contains', 'bob'

    assert_evalutes_false 'bob', 'contains', 'bob2'
    assert_evalutes_false 'bob', 'contains', 'a'
    assert_evalutes_false 'bob', 'contains', '---'
  end

  def test_invalid_comparation_operator
    assert_evaluates_argument_error 1, '~~', 0
  end

  def test_comparation_of_int_and_str
    assert_evaluates_argument_error '1', '>', 0
    assert_evaluates_argument_error '1', '<', 0
    assert_evaluates_argument_error '1', '>=', 0
    assert_evaluates_argument_error '1', '<=', 0
  end

  def test_contains_works_on_arrays
    @context = Liquid::Context.new
    @context['array'] = [1, 2, 3, 4, 5]
    array_expr = VariableLookup.new("array")

    assert_evalutes_false array_expr, 'contains', 0
    assert_evalutes_true array_expr, 'contains', 1
    assert_evalutes_true array_expr, 'contains', 2
    assert_evalutes_true array_expr, 'contains', 3
    assert_evalutes_true array_expr, 'contains', 4
    assert_evalutes_true array_expr, 'contains', 5
    assert_evalutes_false array_expr, 'contains', 6
    assert_evalutes_false array_expr, 'contains', "1"
  end

  def test_contains_returns_false_for_nil_operands
    @context = Liquid::Context.new
    assert_evalutes_false VariableLookup.new('not_assigned'), 'contains', '0'
    assert_evalutes_false 0, 'contains', VariableLookup.new('not_assigned')
  end

  def test_contains_return_false_on_wrong_data_type
    assert_evalutes_false 1, 'contains', 0
  end

  def test_contains_with_string_left_operand_coerces_right_operand_to_string
    assert_evalutes_true ' 1 ', 'contains', 1
    assert_evalutes_false ' 1 ', 'contains', 2
  end

  def test_or_condition
    condition = Condition.new(1, '==', 2)

    assert_equal false, condition.evaluate

    condition.or Condition.new(2, '==', 1)

    assert_equal false, condition.evaluate

    condition.or Condition.new(1, '==', 1)

    assert_equal true, condition.evaluate
  end

  def test_and_condition
    condition = Condition.new(1, '==', 1)

    assert_equal true, condition.evaluate

    condition.and Condition.new(2, '==', 2)

    assert_equal true, condition.evaluate

    condition.and Condition.new(2, '==', 1)

    assert_equal false, condition.evaluate
  end

  def test_should_allow_custom_proc_operator
    Condition.operators['starts_with'] = proc { |cond, left, right| left =~ %r{^#{right}} }

    assert_evalutes_true 'bob', 'starts_with', 'b'
    assert_evalutes_false 'bob', 'starts_with', 'o'
  ensure
    Condition.operators.delete 'starts_with'
  end

  def test_left_or_right_may_contain_operators
    @context = Liquid::Context.new
    @context['one'] = @context['another'] = "gnomeslab-and-or-liquid"

    assert_evalutes_true VariableLookup.new("one"), '==', VariableLookup.new("another")
  end

  private

  def assert_evalutes_true(left, op, right)
    assert Condition.new(left, op, right).evaluate(@context || Liquid::Context.new),
      "Evaluated false: #{left} #{op} #{right}"
  end

  def assert_evalutes_false(left, op, right)
    assert !Condition.new(left, op, right).evaluate(@context || Liquid::Context.new),
      "Evaluated true: #{left} #{op} #{right}"
  end

  def assert_evaluates_argument_error(left, op, right)
    assert_raises(Liquid::ArgumentError) do
      Condition.new(left, op, right).evaluate(@context || Liquid::Context.new)
    end
  end
end # ConditionTest
