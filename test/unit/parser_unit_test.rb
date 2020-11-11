# frozen_string_literal: true

require 'test_helper'

class ParserUnitTest < Minitest::Test
  include Liquid

  def test_consume
    p = Parser.new("wat: 7")
    assert_equal('wat', p.consume(:id))
    assert_equal(':', p.consume(:colon))
    assert_equal('7', p.consume(:number))
  end

  def test_jump
    p = Parser.new("wat: 7")
    p.jump(2)
    assert_equal('7', p.consume(:number))
  end

  def test_consume?
    p = Parser.new("wat: 7")
    assert_equal('wat', p.consume?(:id))
    assert_equal(false, p.consume?(:dot))
    assert_equal(':', p.consume(:colon))
    assert_equal('7', p.consume?(:number))
  end

  def test_id?
    p = Parser.new("wat 6 Peter Hegemon")
    assert_equal('wat', p.id?('wat'))
    assert_equal(false, p.id?('endgame'))
    assert_equal('6', p.consume(:number))
    assert_equal('Peter', p.id?('Peter'))
    assert_equal(false, p.id?('Achilles'))
  end

  def test_look
    p = Parser.new("wat 6 Peter Hegemon")
    assert_equal(true, p.look(:id))
    assert_equal('wat', p.consume(:id))
    assert_equal(false, p.look(:comparison))
    assert_equal(true, p.look(:number))
    assert_equal(true, p.look(:id, 1))
    assert_equal(false, p.look(:number, 1))
  end

  def test_expressions
    p = Parser.new("hi.there hi?[5].there? hi.there.bob")
    assert_equal(VariableLookup.new('hi', ['there'], 0), p.expression)
    assert_equal(VariableLookup.new('hi?', [5, 'there?'], 0), p.expression)
    assert_equal(VariableLookup.new('hi', ['there', 'bob'], 0), p.expression)

    p = Parser.new("nil true false")
    assert_nil(p.expression)
    assert_equal(true, p.expression)
    assert_equal(false, p.expression)

    p = Parser.new("567 6.0 'lol' \"wut\"")
    assert_equal(567, p.expression)
    assert_equal(6.0, p.expression)
    assert_equal('lol', p.expression)
    assert_equal('wut', p.expression)
  end

  def test_ranges
    p = Parser.new("(5..7) (1.5..9.6) (young..old) (hi[5].wat..old)")
    assert_equal(5..7, p.expression)
    assert_equal(1..9, p.expression)
    assert_equal(RangeLookup.new(VariableLookup.new('young', [], 0), VariableLookup.new('old', [], 0)), p.expression)
    assert_equal(RangeLookup.new(VariableLookup.new('hi', [5, "wat"], 0), VariableLookup.new('old', [], 0)), p.expression)
  end

  def test_arguments
    p = Parser.new("filter: hi.there[5], keyarg: 7")
    assert_equal('filter', p.consume(:id))
    assert_equal(':', p.consume(:colon))
    assert_equal([[VariableLookup.new("hi", ["there", 5], 0)], { "keyarg" => 7 }], p.arguments)
  end

  def test_invalid_expression
    assert_raises(SyntaxError) do
      p = Parser.new("==")
      p.expression
    end
  end
end
