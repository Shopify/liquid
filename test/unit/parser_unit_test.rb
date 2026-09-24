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

  def test_assignment_delimiter
    parser = new_parser('title = product.title')
    assert_equal('title', parser.consume(:id))
    assert_equal('=', parser.consume(:assign))
    assert_equal('product.title', parser.expression)
    parser.consume(:end_of_string)
  end

  def test_callable_expression_consumes_only_its_arguments
    context = ParseContext.new(error_mode: :strict2)
    parser = context.new_parser('title(product, nested(1),), next')
    expression = context.safe_parse_expression(parser)
    assert_instance_of(CallExpression, expression)
    assert_equal('title', expression.target.name)
    assert_equal('product', expression.arguments.first.name)
    assert_instance_of(CallExpression, expression.arguments.last)
    assert_equal([1], expression.arguments.last.arguments)
    parser.consume(:comma)
    assert_equal('next', parser.consume(:id))
    parser.consume(:end_of_string)
  end

  def test_expression_markup_preserves_callable_syntax_without_consuming_attributes
    [
      ['(1 .. finish( ))', '(1..finish())', RangeLookup],
      ['groups[ key( ) ].items', 'groups[key()].items', VariableLookup],
      ['identity( "a b", nested(1) )', 'identity("a b",nested(1))', CallExpression],
    ].each do |source, expected_markup, expected_class|
      parser = ParseContext.new(error_mode: :strict2).new_parser("#{source} limit: 1")
      value, markup = parser.expression_with_markup
      assert_instance_of(expected_class, value)
      assert_equal(expected_markup, markup)
      assert_equal('limit', parser.consume(:id))
      parser.consume(:colon)
      assert_equal('1', parser.consume(:number))
      parser.consume(:end_of_string)
    end
  end

  def test_expression_markup_preserves_non_callable_loop_names
    ['items', 'groups[key].items', '(1..finish)', '"a b"'].each do |source|
      value, markup = new_parser(source).expression_with_markup
      assert_equal(source, value)
      assert_equal(source, markup)
    end
  end

  def test_parameters_consume_parentheses_and_optional_trailing_comma
    parser = new_parser('(first, second,)')
    assert_equal(['first', 'second'], parser.parameters)
    parser.consume(:end_of_string)
    assert_equal([], new_parser('()').parameters)
  end

  def test_callable_grammar_uses_effective_partial_mode
    environment = Environment.build(error_mode: :strict)
    context = ParseContext.new(environment: environment, error_mode: :strict2, include_options_blacklist: [:error_mode])
    assert_instance_of(CallExpression, context.safe_parse_expression(context.new_parser('title()')))
    context.partial = true
    parser = context.new_parser('title()')
    assert_equal('title', parser.expression)
    assert_raises(SyntaxError) { parser.consume(:end_of_string) }
  end

  def test_callable_grammar_is_explicitly_disabled_in_other_modes
    [:lax, :warn, :strict, :rigid].each do |mode|
      parser = ParseContext.new(error_mode: mode).new_parser('title(1)')
      assert_equal('title', parser.expression)
      assert_raises(SyntaxError) { parser.consume(:end_of_string) }
    end
  end

  private

  def new_parser(str)
    Parser.new(StringScanner.new(str))
  end
end
