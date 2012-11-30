require 'test_helper'

class ConditionTest < Test::Unit::TestCase
  include Liquid

  def test_basic_condition
    assert_equal false, Condition.new('1', '==', '2').evaluate
    assert_equal true,  Condition.new('1', '==', '1').evaluate
  end

  def test_default_operators_evalute_true
    assert_evalutes_true '1', '==', '1'
    assert_evalutes_true "'1'", '==', '1'
    assert_evalutes_true "'alpha'", '==', "'alpha'"
    assert_evalutes_true "'true'", '==', "true"
    assert_evalutes_true "true", '==', "true"
    assert_evalutes_true '1', '!=', '2'
    assert_evalutes_true "'alpha'", '!=', "'beta'"
    assert_evalutes_true "'false'", '!=', "true"
    assert_evalutes_true "false", '!=', "true"
    assert_evalutes_true '1', '<>', '2'
    assert_evalutes_true "'alpha'", '<>', "'beta'"
    assert_evalutes_true "'false'", '<>', "true"
    assert_evalutes_true "false", '<>', "true"
    assert_evalutes_true '1', '<', '2'
    assert_evalutes_true "'1'", '<', '2'
    assert_evalutes_true "'alpha'", '<', "'beta'"
    assert_evalutes_true '2', '>', '1'
    assert_evalutes_true "'2'", '>', '1'
    assert_evalutes_true "'3'", '<', "'10'"
    assert_evalutes_true "'10'", '>', "'3'"
    assert_evalutes_true "'beta'", '>', "'alpha'"
    assert_evalutes_true '1', '>=', '1'
    assert_evalutes_true '2', '>=', '1'
    assert_evalutes_true "'1'", '>=', '1'
    assert_evalutes_true "'2'", '>=', '1'
    assert_evalutes_true '1', '<=', '2'
    assert_evalutes_true '1', '<=', '1'
    assert_evalutes_true "'1'", '<=', '2'
    assert_evalutes_true "'1'", '<=', '1'
  end

  def test_default_operators_evalute_false
    assert_evalutes_false '1', '==', '2'
    assert_evalutes_false "'alpha'", '==', "'beta'"
    assert_evalutes_false "'false'", '==', "true"
    assert_evalutes_false '1', '!=', '1'
    assert_evalutes_false "'alpha'", '!=', "'alpha'"
    assert_evalutes_false "'true'", '!=', "true"
    assert_evalutes_false "'1'", '!=', '1'
    assert_evalutes_false '1', '<>', '1'
    assert_evalutes_false "'alpha'", '<>', "'alpha'"
    assert_evalutes_false "'true'", '<>', "true"
    assert_evalutes_false "'1'", '<>', '1'
    assert_evalutes_false '1', '<', '0'
    assert_evalutes_false '2', '>', '4'
    assert_evalutes_false "'1'", '<', '0'
    assert_evalutes_false "'2'", '>', '4'
    assert_evalutes_false "'10'", '<', "'3'"
    assert_evalutes_false "'3'", '>', "'10'"
    assert_evalutes_false "'alpha'", '>', "'beta'"
    assert_evalutes_false "'beta'", '<', "'alpha'"
    assert_evalutes_false '1', '>=', '3'
    assert_evalutes_false '2', '>=', '4'
    assert_evalutes_false "'1'", '>=', '3'
    assert_evalutes_false '2', '>=', "'4'"
    assert_evalutes_false '1', '<=', '0'
    assert_evalutes_false '1', '<=', '0'
    assert_evalutes_false "'1'", '<=', '0'
    assert_evalutes_false '1', '<=', "'0'"
  end

  def test_contains_works_on_strings
    assert_evalutes_true "'bob'", 'contains', "'o'"
    assert_evalutes_true "'bob'", 'contains', "'b'"
    assert_evalutes_true "'bob'", 'contains', "'bo'"
    assert_evalutes_true "'bob'", 'contains', "'ob'"
    assert_evalutes_true "'bob'", 'contains', "'bob'"

    assert_evalutes_false "'bob'", 'contains', "'bob2'"
    assert_evalutes_false "'bob'", 'contains', "'a'"
    assert_evalutes_false "'bob'", 'contains', "'---'"
  end

  def test_contains_works_on_arrays
    @context = Liquid::Context.new
    @context['array'] = [1,2,3,4,5]

    assert_evalutes_false "array",  'contains', '0'
    assert_evalutes_true "array",   'contains', '1'
    assert_evalutes_true "array",   'contains', '2'
    assert_evalutes_true "array",   'contains', '3'
    assert_evalutes_true "array",   'contains', '4'
    assert_evalutes_true "array",   'contains', '5'
    assert_evalutes_false "array",  'contains', '6'
    assert_evalutes_false "array",  'contains', '"1"'
  end

  def test_contains_returns_false_for_nil_operands
    @context = Liquid::Context.new
    assert_evalutes_false "not_assigned", 'contains', '0'
    assert_evalutes_false "0", 'contains', 'not_assigned'
  end

  def test_contains_raises_error_for_nil_operands_if_strict
    @context = Liquid::Context.new
    @context.strict = true
    assert_raise(VariableNotFound) do
      assert_evalutes_false "not_assigned", 'contains', '0'
    end
  end

  def test_or_condition
    condition = Condition.new('1', '==', '2')

    assert_equal false, condition.evaluate

    condition.or Condition.new('2', '==', '1')

    assert_equal false, condition.evaluate

    condition.or Condition.new('1', '==', '1')

    assert_equal true, condition.evaluate
  end

  def test_and_condition
    condition = Condition.new('1', '==', '1')

    assert_equal true, condition.evaluate

    condition.and Condition.new('2', '==', '2')

    assert_equal true, condition.evaluate

    condition.and Condition.new('2', '==', '1')

    assert_equal false, condition.evaluate
  end

  def test_should_allow_custom_proc_operator
    Condition.operators['starts_with'] = Proc.new { |cond, left, right| left =~ %r{^#{right}} }

    assert_evalutes_true "'bob'",   'starts_with', "'b'"
    assert_evalutes_false "'bob'",  'starts_with', "'o'"

    ensure
      Condition.operators.delete 'starts_with'
  end

  def test_left_or_right_may_contain_operators
    @context = Liquid::Context.new
    @context['one'] = @context['another'] = "gnomeslab-and-or-liquid"

    assert_evalutes_true "one", '==', "another"
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
end # ConditionTest
