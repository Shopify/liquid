require 'test_helper'

class ParserTest < Test::Unit::TestCase
  include Liquid

  def test_consume
    p = Parser.new("wat: 7")
    assert_equal 'wat', p.consume(:id)
    assert_equal ':', p.consume(:colon)
    assert_equal '7', p.consume(:integer)
  end

  def test_jump
    p = Parser.new("wat: 7")
    p.jump(2)
    assert_equal '7', p.consume(:integer)
  end

  def test_consume?
    p = Parser.new("wat: 7")
    assert_equal 'wat', p.consume?(:id)
    assert_equal false, p.consume?(:dot)
    assert_equal ':', p.consume(:colon)
    assert_equal '7', p.consume?(:integer)
  end

  def test_id?
    p = Parser.new("wat 6 Peter Hegemon")
    assert_equal 'wat', p.id?('wat')
    assert_equal false, p.id?('endgame')
    assert_equal '6', p.consume(:integer)
    assert_equal 'Peter', p.id?('Peter')
    assert_equal false, p.id?('Achilles')
  end

  def test_look
    p = Parser.new("wat 6 Peter Hegemon")
    assert_equal true, p.look(:id)
    assert_equal 'wat', p.consume(:id)
    assert_equal false, p.look(:float)
    assert_equal true, p.look(:integer)
    assert_equal true, p.look(:id, 1)
    assert_equal false, p.look(:float, 1)
  end

  def test_expressions
    p = Parser.new("hi.there hi[5].! hi.there.bob")
    assert_equal 'hi.there', p.expression
    assert_equal 'hi[5].!', p.expression
    assert_equal 'hi.there.bob', p.expression

    p = Parser.new("567 6.0 'lol' \"wut\"")
    assert_equal '567', p.expression
    assert_equal '6.0', p.expression
    assert_equal "'lol'", p.expression
    assert_equal '"wut"', p.expression
  end

  def test_arguments
    p = Parser.new("filter: hi.there[5], keyarg: 7")
    assert_equal 'filter', p.consume(:id)
    assert_equal ':', p.consume(:colon)
    assert_equal 'hi.there[5]', p.argument
    assert_equal ',', p.consume(:comma)
    assert_equal 'keyarg: 7', p.argument
  end

  def test_invalid_expression
    assert_raises(SyntaxError) do
      p = Parser.new("==")
      p.expression
    end
  end
end
