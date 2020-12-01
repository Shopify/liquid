# frozen_string_literal: true

require 'test_helper'

class ExpressionTest < Minitest::Test
  def test_keyword_literals
    assert_equal(true, parse_and_eval("true"))
    assert_equal(true, parse_and_eval(" true "))
  end

  def test_string
    assert_equal("single quoted", parse_and_eval("'single quoted'"))
    assert_equal("double quoted", parse_and_eval('"double quoted"'))
    assert_equal("spaced", parse_and_eval(" 'spaced' "))
    assert_equal("spaced2", parse_and_eval(' "spaced2" '))
  end

  def test_int
    assert_equal(123, parse_and_eval("123"))
    assert_equal(456, parse_and_eval(" 456 "))
    assert_equal(12, parse_and_eval("012"))
  end

  def test_float
    assert_equal(1.5, parse_and_eval("1.5"))
    assert_equal(2.5, parse_and_eval(" 2.5 "))
  end

  def test_range
    assert_equal(1..2, parse_and_eval("(1..2)"))
    assert_equal(3..4, parse_and_eval(" ( 3 .. 4 ) "))
  end

  private

  def parse_and_eval(markup, **assigns)
    if Liquid::Template.error_mode == :strict
      p = Liquid::Parser.new(markup)
      markup = p.expression
      p.consume(:end_of_string)
    end
    expression = Liquid::Expression.parse(markup)
    context = Liquid::Context.new(assigns)
    context.evaluate(expression)
  end
end
