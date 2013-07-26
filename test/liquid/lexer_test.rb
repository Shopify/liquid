require 'test_helper'

class LexerTest < Test::Unit::TestCase
  include Liquid

  def test_strings
    tokens = Lexer.new(%! 'this is a test""' "wat 'lol'"!).tokenize
    assert_equal [Token[:string,%!'this is a test""'!], Token[:string, %!"wat 'lol'"!], Token[:end_of_string]], tokens
  end

  def test_integer
    tokens = Lexer.new('hi 50').tokenize
    assert_equal [Token[:id,'hi'], Token[:integer, '50'], Token[:end_of_string]], tokens
  end

  def test_float
    tokens = Lexer.new('hi 5.0').tokenize
    assert_equal [Token[:id,'hi'], Token[:float, '5.0'], Token[:end_of_string]], tokens
  end

  def test_comparison
    tokens = Lexer.new('== <> contains').tokenize
    assert_equal [Token[:comparison,'=='], Token[:comparison, '<>'], Token[:comparison, 'contains'], Token[:end_of_string]], tokens
  end

  def test_specials
    tokens = Lexer.new('| .:').tokenize
    assert_equal [Token[:pipe, '|'], Token[:dot, '.'], Token[:colon, ':'], Token[:end_of_string]], tokens
    tokens = Lexer.new('[,]').tokenize
    assert_equal [Token[:open_square, '['], Token[:comma, ','], Token[:close_square, ']'], Token[:end_of_string]], tokens
  end

  def test_fancy_identifiers
    tokens = Lexer.new('hi! five?').tokenize
    assert_equal [Token[:id,'hi!'], Token[:id, 'five?'], Token[:end_of_string]], tokens
  end

  def test_whitespace
    tokens = Lexer.new("five|\n\t ==").tokenize
    assert_equal [Token[:id,'five'], Token[:pipe, '|'], Token[:comparison, '=='], Token[:end_of_string]], tokens
  end

  def test_unexpected_character
    assert_raises(SyntaxError) do
      Lexer.new("%").tokenize
    end
  end

  def test_next_token
    l = Lexer.new('hi 5.0')
    assert_equal Token[:id, 'hi'], l.next_token
    assert_equal Token[:float, '5.0'], l.next_token
    assert_nil l.next_token
  end
end
