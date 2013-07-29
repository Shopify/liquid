require 'test_helper'

class LexerTest < Test::Unit::TestCase
  include Liquid

  def test_strings
    tokens = Lexer.new(%! 'this is a test""' "wat 'lol'"!).tokenize
    assert_equal [Token.new(:string,%!'this is a test""'!), Token.new(:string, %!"wat 'lol'"!), Token.new(:end_of_string)], tokens
  end

  def test_integer
    tokens = Lexer.new('hi 50').tokenize
    assert_equal [Token.new(:id,'hi'), Token.new(:integer, '50'), Token.new(:end_of_string)], tokens
  end

  def test_float
    tokens = Lexer.new('hi 5.0').tokenize
    assert_equal [Token.new(:id,'hi'), Token.new(:float, '5.0'), Token.new(:end_of_string)], tokens
  end

  def test_comparison
    tokens = Lexer.new('== <> contains').tokenize
    assert_equal [Token.new(:comparison,'=='), Token.new(:comparison, '<>'), Token.new(:comparison, 'contains'), Token.new(:end_of_string)], tokens
  end

  def test_specials
    tokens = Lexer.new('| .:').tokenize
    assert_equal [Token.new(:pipe, '|'), Token.new(:dot, '.'), Token.new(:colon, ':'), Token.new(:end_of_string)], tokens
    tokens = Lexer.new('[,]').tokenize
    assert_equal [Token.new(:open_square, '['), Token.new(:comma, ','), Token.new(:close_square, ']'), Token.new(:end_of_string)], tokens
  end

  def test_fancy_identifiers
    tokens = Lexer.new('hi! five?').tokenize
    assert_equal [Token.new(:id,'hi!'), Token.new(:id, 'five?'), Token.new(:end_of_string)], tokens
  end

  def test_whitespace
    tokens = Lexer.new("five|\n\t ==").tokenize
    assert_equal [Token.new(:id,'five'), Token.new(:pipe, '|'), Token.new(:comparison, '=='), Token.new(:end_of_string)], tokens
  end

  def test_unexpected_character
    assert_raises(SyntaxError) do
      Lexer.new("%").tokenize
    end
  end

  def test_next_token
    l = Lexer.new('hi 5.0')
    assert_equal Token.new(:id, 'hi'), l.next_token
    assert_equal Token.new(:float, '5.0'), l.next_token
    assert_nil l.next_token
  end
end
