# frozen_string_literal: true

require 'test_helper'

class LexerUnitTest < Minitest::Test
  include Liquid

  def test_strings
    tokens = Lexer.new(%( 'this is a test""' "wat 'lol'")).tokenize
    assert_equal([[:string, %('this is a test""')], [:string, %("wat 'lol'")], [:end_of_string]], tokens)
  end

  def test_integer
    tokens = Lexer.new('hi 50').tokenize
    assert_equal([[:id, 'hi'], [:number, '50'], [:end_of_string]], tokens)
  end

  def test_float
    tokens = Lexer.new('hi 5.0').tokenize
    assert_equal([[:id, 'hi'], [:number, '5.0'], [:end_of_string]], tokens)
  end

  def test_comparison
    tokens = Lexer.new('== <> contains ').tokenize
    assert_equal([[:comparison, '=='], [:comparison, '<>'], [:comparison, 'contains'], [:end_of_string]], tokens)
  end

  def test_comparison_without_whitespace
    tokens = Lexer.new('1>0').tokenize
    assert_equal([[:number, '1'], [:comparison, '>'], [:number, '0'], [:end_of_string]], tokens)
  end

  def test_comparison_with_negative_number
    tokens = Lexer.new('1>-1').tokenize
    assert_equal([[:number, '1'], [:comparison, '>'], [:number, '-1'], [:end_of_string]], tokens)
  end

  def test_raise_for_invalid_comparison
    assert_raises(SyntaxError) do
      Lexer.new('1>!1').tokenize
    end

    assert_raises(SyntaxError) do
      Lexer.new('1=<1').tokenize
    end

    assert_raises(SyntaxError) do
      Lexer.new('1!!1').tokenize
    end
  end

  def test_specials
    tokens = Lexer.new('| .:').tokenize
    assert_equal([[:pipe, '|'], [:dot, '.'], [:colon, ':'], [:end_of_string]], tokens)
    tokens = Lexer.new('[,]').tokenize
    assert_equal([[:open_square, '['], [:comma, ','], [:close_square, ']'], [:end_of_string]], tokens)
  end

  def test_fancy_identifiers
    tokens = Lexer.new('hi five?').tokenize
    assert_equal([[:id, 'hi'], [:id, 'five?'], [:end_of_string]], tokens)

    tokens = Lexer.new('2foo').tokenize
    assert_equal([[:number, '2'], [:id, 'foo'], [:end_of_string]], tokens)
  end

  def test_whitespace
    tokens = Lexer.new("five|\n\t ==").tokenize
    assert_equal([[:id, 'five'], [:pipe, '|'], [:comparison, '=='], [:end_of_string]], tokens)
  end

  def test_unexpected_character
    assert_raises(SyntaxError) do
      Lexer.new("%").tokenize
    end
  end

  def test_negative_numbers
    tokens = Lexer.new("foo | default: -1").tokenize
    assert_equal([[:id, 'foo'], [:pipe, '|'], [:id, 'default'], [:colon, ":"], [:number, '-1'], [:end_of_string]], tokens)
  end

  def test_greater_than_two_digits
    tokens = Lexer.new("foo > 12").tokenize
    assert_equal([[:id, 'foo'], [:comparison, '>'], [:number, '12'], [:end_of_string]], tokens)
  end

  def test_error_with_utf8_character
    error = assert_raises(SyntaxError) do
      Lexer.new("1 < 1Ø").tokenize
    end

    assert_equal(
      'Liquid syntax error: Unexpected character Ø',
      error.message,
    )
  end
end
