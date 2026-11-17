# frozen_string_literal: true

require 'test_helper'

class LexerUnitTest < Minitest::Test
  include Liquid

  def test_strings
    assert_equal(
      [[:string, %('this is a test""')], [:string, %("wat 'lol'")], [:end_of_string]],
      tokenize(%( 'this is a test""' "wat 'lol'")),
    )
  end

  def test_integer
    assert_equal(
      [[:id, 'hi'], [:number, '50'], [:end_of_string]],
      tokenize('hi 50'),
    )
  end

  def test_float
    assert_equal(
      [[:id, 'hi'], [:number, '5.0'], [:end_of_string]],
      tokenize('hi 5.0'),
    )
  end

  def test_comparison
    assert_equal(
      [[:comparison, '=='], [:comparison, '<>'], [:comparison, 'contains'], [:end_of_string]],
      tokenize('== <> contains '),
    )
  end

  def test_comparison_without_whitespace
    assert_equal(
      [[:number, '1'], [:comparison, '>'], [:number, '0'], [:end_of_string]],
      tokenize('1>0'),
    )
  end

  def test_comparison_with_negative_number
    assert_equal(
      [[:number, '1'], [:comparison, '>'], [:number, '-1'], [:end_of_string]],
      tokenize('1>-1'),
    )
  end

  def test_raise_for_invalid_comparison
    assert_raises(SyntaxError) do
      tokenize('1>!1')
    end

    assert_raises(SyntaxError) do
      tokenize('1=<1')
    end

    assert_raises(SyntaxError) do
      tokenize('1!!1')
    end
  end

  def test_specials
    assert_equal(
      [[:pipe, '|'], [:dot, '.'], [:colon, ':'], [:end_of_string]],
      tokenize('| .:'),
    )

    assert_equal(
      [[:open_square, '['], [:comma, ','], [:close_square, ']'], [:end_of_string]],
      tokenize('[,]'),
    )
  end

  def test_fancy_identifiers
    assert_equal([[:id, 'hi'], [:id, 'five?'], [:end_of_string]], tokenize('hi five?'))

    assert_equal([[:number, '2'], [:id, 'foo'], [:end_of_string]], tokenize('2foo'))
  end

  def test_whitespace
    assert_equal(
      [[:id, 'five'], [:pipe, '|'], [:comparison, '=='], [:end_of_string]],
      tokenize("five|\n\t =="),
    )
  end

  def test_unexpected_character
    assert_raises(SyntaxError) do
      tokenize("%")
    end
  end

  def test_negative_numbers
    assert_equal(
      [[:id, 'foo'], [:pipe, '|'], [:id, 'default'], [:colon, ":"], [:number, '-1'], [:end_of_string]],
      tokenize("foo | default: -1"),
    )
  end

  def test_greater_than_two_digits
    assert_equal(
      [[:id, 'foo'], [:comparison, '>'], [:number, '12'], [:end_of_string]],
      tokenize("foo > 12"),
    )
  end

  def test_error_with_utf8_character
    error = assert_raises(SyntaxError) do
      tokenize("1 < 1Ø")
    end

    assert_equal(
      'Liquid syntax error: Unexpected character Ø',
      error.message,
    )
  end

  def test_contains_as_attribute_name
    assert_equal(
      [[:id, "a"], [:dot, "."], [:id, "contains"], [:dot, "."], [:id, "b"], [:end_of_string]],
      tokenize("a.contains.b"),
    )
  end

  def test_tokenize_incomplete_expression
    assert_equal([[:id, "false"], [:dash, "-"], [:end_of_string]], tokenize("false -"))
    assert_equal([[:id, "false"], [:comparison, "<"], [:end_of_string]], tokenize("false <"))
    assert_equal([[:id, "false"], [:comparison, ">"], [:end_of_string]], tokenize("false >"))
    assert_equal([[:id, "false"], [:number, "1"], [:end_of_string]], tokenize("false 1"))
  end

  def test_error_with_invalid_utf8
    error = assert_raises(SyntaxError) do
      tokenize("\x00\xff")
    end
    assert_equal(
      'Liquid syntax error: Invalid byte sequence in UTF-8',
      error.message,
    )
  end

  def test_vertical_tab_is_whitespace
    assert_equal([[:id, "a"], [:id, "b"], [:end_of_string]], tokenize("a\vb"))
  end

  def test_numbers_stop_before_a_dot_without_digits
    assert_equal([[:number, "1"], [:dot, "."], [:end_of_string]], tokenize("1."))
    assert_equal([[:number, "1.2"], [:dot, "."], [:number, "3"], [:end_of_string]], tokenize("1.2.3"))
    assert_equal([[:number, "1"], [:dotdot, ".."], [:number, "2"], [:end_of_string]], tokenize("1..2"))
  end

  def test_identifiers_with_dashes_and_question_marks
    assert_equal([[:id, "a-b?"], [:id, "c"], [:end_of_string]], tokenize("a-b?c"))
    assert_equal([[:id, "a"], [:question, "?"], [:end_of_string]], tokenize("a ?"))
  end

  def test_error_with_unterminated_string
    error = assert_raises(SyntaxError) { tokenize("'abc") }
    assert_equal("Liquid syntax error: Unexpected character '", error.message)
  end

  def test_error_with_lone_equals_sign
    error = assert_raises(SyntaxError) { tokenize("a = b") }
    assert_equal("Liquid syntax error: Unexpected character =", error.message)
  end

  def test_error_with_ascii_incompatible_encoding
    assert_raises(Encoding::CompatibilityError) { tokenize("a".encode(Encoding::UTF_16LE)) }
  end

  def test_tokens_keep_the_source_encoding
    tokens = tokenize("a 'b'".b)

    assert_equal([[:id, "a"], [:string, "'b'"], [:end_of_string]], tokens)
    assert_equal(Encoding::BINARY, tokens[0][1].encoding)
  end

  def test_tokenize_a_string_scanner
    require "strscan"
    scanner = StringScanner.new("foo.bar")

    assert_equal([[:id, "foo"], [:dot, "."], [:id, "bar"], [:end_of_string]], Lexer.tokenize(scanner))
    assert_predicate(scanner, :eos?)
  end

  def test_string_scanner_stops_after_an_unexpected_character
    require "strscan"
    scanner = StringScanner.new("a Ø b")

    assert_raises(SyntaxError) { Lexer.tokenize(scanner) }
    assert_equal(4, scanner.pos)
  end

  def test_raise_syntax_error_with_a_string_scanner
    require "strscan"
    scanner = StringScanner.new("a Ø b")
    error = assert_raises(SyntaxError) { Lexer.raise_syntax_error(2, scanner) }

    assert_equal("Liquid syntax error: Unexpected character Ø", error.message)
    assert_equal(4, scanner.pos)
  end

  def test_error_with_a_non_string_input
    error = assert_raises(::TypeError) { Lexer.tokenize(nil) }
    assert_equal("no implicit conversion of nil into String", error.message)
  end

  private

  def tokenize(input)
    Lexer.tokenize(input)
  end
end
