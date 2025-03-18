# frozen_string_literal: true

require 'test_helper'
require 'test_boolean_helper'

class BooleanPrecedenceUnitTest < Minitest::Test
  include Liquid

  def test_basic_boolean_parenthesized_expressions
    assert_parity("false and (false or true)", "false")
    assert_parity("true and (false or true)", "true")
    assert_parity("(true and false) or true", "true")
    assert_parity("(false and true) or false", "false")
  end

  def test_nested_boolean_parentheses
    assert_parity("(false and (true or false)) or true", "true")
    assert_parity("true and (false or (true and true))", "true")
    assert_parity("(true and (false or false)) or false", "false")
  end

  def test_multiple_operations_with_consistent_operators
    assert_parity("(true and true) and (false or true)", "true")
    assert_parity("(false or false) or (true and false)", "false")
  end

  def test_parentheses_changing_default_precedence
    # Default precedence: (true and false) or true
    assert_parity("true and false or true", "true")
    # With parentheses: true and (false or true)
    assert_parity("true and (false or true)", "true")

    # Default precedence: false or (true and true)
    assert_parity("false or true and true", "true")
    # With parentheses: (false or true) and true
    assert_parity("(false or true) and true", "true")
  end

  def test_boolean_parentheses_with_variables
    assert_parity("(a or b) and c", "true", { "a" => true, "b" => false, "c" => true })
    assert_parity("(a or b) and c", "false", { "a" => true, "b" => false, "c" => false })
    assert_parity("a and (b or c)", "true", { "a" => true, "b" => false, "c" => true })
    assert_parity("a and (b or c)", "false", { "a" => false, "b" => true, "c" => true })
  end

  def test_comparison_operators_inside_parentheses
    assert_parity("(1 > 0) and (2 < 3)", "true")
    assert_parity("(1 < 0) or (2 > 3)", "false")
    assert_parity("true and (1 == 1)", "true")
    assert_parity("false or (2 != 2)", "false")
  end

  def test_complex_nested_boolean_expressions
    assert_parity("((true and false) or (false and true)) or ((false or true) and (true or false))", "true")
    assert_parity("((true and true) or (false and false)) and ((true or false) and (false or true))", "true")
  end

  def test_not_operator_with_parentheses
    # Testing how 'not' interacts with parentheses
    assert_parity("not (true or false)", "false")
    assert_parity("not (false and true)", "true")
    assert_parity("(not false) and true", "true")
    assert_parity("(not true) or false", "false")
    assert_parity("not (not true)", "true")
  end

  def test_nil_values_with_boolean_precedence
    # How nil values interact with boolean expressions and parentheses
    assert_parity("nil and (true or false)", "false")
    assert_parity("(nil or true) and false", "false")
    assert_parity("(nil and nil) or true", "true")
    assert_parity("true and (nil or false)", "false")
  end

  def test_mixed_primitive_types_with_parentheses
    # Testing how different types interact in boolean expressions with parentheses
    assert_parity("('' or 0) and true", "true")
    assert_parity("(true and 'string') or false", "true")
    assert_parity("(false or '') and 1", "false")
    assert_parity("(nil or false) and 'text'", "false")
  end

  def test_triple_operator_precedence
    # Testing three different operators with different parenthesizing
    assert_parity("true or false and true or false", "true") # default precedence
    assert_parity("true or (false and true) or false", "true")
    assert_parity("(true or false) and (true or false)", "true")
    assert_parity("((true or false) and true) or false", "true")
    assert_parity("true or (false and (true or false))", "true")
  end

  def test_undefined_variables_with_parentheses
    # How undefined variables behave with parentheses
    assert_parity("(undefined_var or true) and false", "false")
    assert_parity("true and (undefined_var or false)", "false")
    assert_parity("(undefined_var and true) or true", "true")
    assert_parity("false or (undefined_var and false)", "false")
  end

  def test_comparison_chaining_with_parentheses
    # Testing how comparison chains work with parentheses
    assert_parity("(1 < 2) and (2 < 3) and (3 < 4)", "true")
    assert_parity("(1 < 2) and ((2 > 3) or (3 < 4))", "true")
    assert_parity(
      "(a > b) or ((c < d) and (e == f))",
      "true",
      { "a" => 5, "b" => 3, "c" => 1, "d" => 2, "e" => 7, "f" => 7 },
    )
    assert_parity(
      "(a > b) or ((c < d) and (e == f))",
      "false",
      { "a" => 3, "b" => 5, "c" => 2, "d" => 1, "e" => 7, "f" => 8 },
    )
  end

  def test_deeply_nested_expressions
    # Testing very deep nesting to ensure parser handles it correctly
    assert_parity("(((true and true) or (false and false)) and ((true or false) and (true)))", "true")
    assert_parity(
      "(((a or b) and c) or (d and (e or f)))",
      "true",
      { "a" => false, "b" => true, "c" => true, "d" => true, "e" => true, "f" => false },
    )
  end

  def test_malformed_parentheses
    # Unbalanced parentheses - missing closing parenthesis
    template = "{% if (true and false %}true{% else %}false{% endif %}"
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse(template) }

    # Unbalanced parentheses - missing opening parenthesis
    template = "{% if true and false) %}true{% else %}false{% endif %}"
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse(template) }

    # Empty parentheses
    template = "{% if () %}true{% else %}false{% endif %}"
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse(template) }

    # Consecutive opening parentheses without operators
    template = "{% if ((true) %}true{% else %}false{% endif %}"
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse(template) }

    # Consecutive closing parentheses without proper opening
    template = "{% if (true)) %}true{% else %}false{% endif %}"
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse(template) }

    # Parentheses with missing operand
    template = "{% if (and true) %}true{% else %}false{% endif %}"
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse(template) }

    # Operator followed immediately by closing parenthesis
    template = "{% if (true and) %}true{% else %}false{% endif %}"
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse(template) }

    # Nested malformed parentheses
    template = "{% if (true and (false or true) %}true{% else %}false{% endif %}"
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse(template) }

    # Double parentheses with no content between them
    template = "{% if true and (()) %}true{% else %}false{% endif %}"
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse(template) }

    # Misplaced parentheses around operators
    template = "{% if true (and) false %}true{% else %}false{% endif %}"
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse(template) }

    # Parentheses at wrong position in expression
    template = "{% if true) and (false %}true{% else %}false{% endif %}"
    assert_raises(Liquid::SyntaxError) { Liquid::Template.parse(template) }
  end
end
