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

  def test_expressions
    p = new_parser("hi.there hi?[5].there? hi.there.bob")
    assert_equal('hi.there', p.expression)
    assert_equal('hi?[5].there?', p.expression)
    assert_equal('hi.there.bob', p.expression)

    p = new_parser("567 6.0 'lol' \"wut\"")
    assert_equal('567', p.expression)
    assert_equal('6.0', p.expression)
    assert_equal("'lol'", p.expression)
    assert_equal('"wut"', p.expression)
  end

  def test_ranges
    p = new_parser("(5..7) (1.5..9.6) (young..old) (hi[5].wat..old)")
    assert_equal('(5..7)', p.expression)
    assert_equal('(1.5..9.6)', p.expression)
    assert_equal('(young..old)', p.expression)
    assert_equal('(hi[5].wat..old)', p.expression)
  end

  def test_arguments
    p = new_parser("filter: hi.there[5], keyarg: 7")
    assert_equal('filter', p.consume(:id))
    assert_equal(':', p.consume(:colon))
    assert_equal('hi.there[5]', p.argument)
    assert_equal(',', p.consume(:comma))
    assert_equal('keyarg: 7', p.argument)
  end

  def test_invalid_expression
    assert_raises(SyntaxError) do
      p = new_parser("==")
      p.expression
    end
  end

  private

  def new_parser(str)
    Parser.new(str, StringScanner.new(""))
  end
end
