# frozen_string_literal: true

require 'test_helper'

class ParserUnitTest < Minitest::Test
  include Liquid

  def test_consume
    p = new_parser("wat: 7")
    assert_equal('wat', p.consume(:id))
    assert_equal(':', p.consume(:colon))
    assert_equal('7', p.consume(:number))
  end

  def test_jump
    p = new_parser("wat: 7")
    p.jump(2)
    assert_equal('7', p.consume(:number))
  end

  def test_consume?
    p = new_parser("wat: 7")
    assert_equal('wat', p.consume?(:id))
    assert_equal(false, p.consume?(:dot))
    assert_equal(':', p.consume(:colon))
    assert_equal('7', p.consume?(:number))
  end

  def test_id?
    p = new_parser("wat 6 Peter Hegemon")
    assert_equal('wat', p.id?('wat'))
    assert_equal(false, p.id?('endgame'))
    assert_equal('6', p.consume(:number))
    assert_equal('Peter', p.id?('Peter'))
    assert_equal(false, p.id?('Achilles'))
  end

  def test_look
    p = new_parser("wat 6 Peter Hegemon")
    assert_equal(true, p.look(:id))
    assert_equal('wat', p.consume(:id))
    assert_equal(false, p.look(:comparison))
    assert_equal(true, p.look(:number))
    assert_equal(true, p.look(:id, 1))
    assert_equal(false, p.look(:number, 1))
  end

  def test_expression_string
    p = new_parser("hi.there hi?[5].there? hi.there.bob")
    assert_equal('hi.there', p.expression_string)
    assert_equal('hi?[5].there?', p.expression_string)
    assert_equal('hi.there.bob', p.expression_string)

    p = new_parser("567 6.0 'lol' \"wut\"")
    assert_equal('567', p.expression_string)
    assert_equal('6.0', p.expression_string)
    assert_equal("'lol'", p.expression_string)
    assert_equal('"wut"', p.expression_string)
  end

  def test_expression
    p = new_parser("hi.there hi?[5].there? hi.there.bob")
    v1 = p.expression
    v2 = p.expression
    v3 = p.expression
    assert(v1.is_a?(VariableLookup) && v1.name == 'hi' && v1.lookups[0] == 'there')
    assert(v2.is_a?(VariableLookup) && v2.name == 'hi?' && v2.lookups[0] == 5)
    assert(v3.is_a?(VariableLookup) && v3.name == 'hi' && v3.lookups[0] == 'there')

    p = new_parser("567 6.0 'lol' \"wut\" true false (0..5)")
    assert_equal(567, p.expression)
    assert_equal(6.0, p.expression)
    assert_equal('lol', p.expression)
    assert_equal('wut', p.expression)
    assert_equal(true, p.expression)
    assert_equal(false, p.expression)
    assert_equal((0..5), p.expression)
  end

  def test_number
    p = new_parser('-1 0 1 2.0')
    assert_equal(-1, p.number)
    assert_equal(0, p.number)
    assert_equal(1, p.number)
    assert_equal(2.0, p.number)
  end

  def test_string
    p = new_parser("'s1' \"s2\" 'this \"s3\"' \"that 's4'\"")
    assert_equal('s1', p.string)
    assert_equal('s2', p.string)
    assert_equal('this "s3"', p.string)
    assert_equal("that 's4'", p.string)
  end

  def test_unnamed_variable_lookup
    p = new_parser('[key].title')
    v = p.expression
    assert(v.is_a?(VariableLookup))
    assert(v.name.is_a?(VariableLookup))
    assert_equal('key', v.name.name)
    assert_equal('title', v.lookups[0])
  end

  def test_range_lookup
    p = new_parser('(0..5) (a..b)')
    assert_equal((0..5), p.expression)

    r2 = p.expression
    assert(r2.is_a?(RangeLookup))
    assert_equal((1..4), r2.evaluate(Context.new({ 'a' => 1, 'b' => 4 })))
  end

  def test_ranges
    p = new_parser("(5..7) (1.5..9.6) (young..old) (hi[5].wat..old)")
    assert_equal('(5..7)', p.expression_string)
    assert_equal('(1.5..9.6)', p.expression_string)
    assert_equal('(young..old)', p.expression_string)
    assert_equal('(hi[5].wat..old)', p.expression_string)
  end

  def test_argument_string
    p = new_parser("filter: hi.there[5], keyarg: 7")
    assert_equal('filter', p.consume(:id))
    assert_equal(':', p.consume(:colon))
    assert_equal('hi.there[5]', p.argument_string)
    assert_equal(',', p.consume(:comma))
    assert_equal('keyarg: 7', p.argument_string)
  end

  def test_invalid_expression
    assert_raises(SyntaxError) do
      p = new_parser("==")
      p.expression_string
    end
  end

  private

  def new_parser(str)
    Parser.new(StringScanner.new(str))
  end
end
