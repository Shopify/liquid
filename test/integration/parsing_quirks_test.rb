require 'test_helper'

class ParsingQuirksTest < Minitest::Test
  include Liquid

  def test_parsing_css
    text = " div { font-weight: bold; } "
    assert_equal text, Template.parse(text).render!
  end

  def test_raise_on_single_close_bracet
    assert_raises(SyntaxError) do
      Template.parse("text {{method} oh nos!")
    end
  end

  def test_raise_on_label_and_no_close_bracets
    assert_raises(SyntaxError) do
      Template.parse("TEST {{ ")
    end
  end

  def test_raise_on_label_and_no_close_bracets_percent
    assert_raises(SyntaxError) do
      Template.parse("TEST {% ")
    end
  end

  def test_error_on_empty_filter
    assert Template.parse("{{test}}")
    assert Template.parse("{{|test}}")
    with_error_mode(:strict) do
      assert_raises(SyntaxError) do
        Template.parse("{{test |a|b|}}")
      end
    end
  end

  def test_meaningless_parens_error
    with_error_mode(:strict) do
      assert_raises(SyntaxError) do
        markup = "a == 'foo' or (b == 'bar' and c == 'baz') or false"
        Template.parse("{% if #{markup} %} YES {% endif %}")
      end
    end
  end

  def test_unexpected_characters_syntax_error
    with_error_mode(:strict) do
      assert_raises(SyntaxError) do
        markup = "true && false"
        Template.parse("{% if #{markup} %} YES {% endif %}")
      end
      assert_raises(SyntaxError) do
        markup = "false || true"
        Template.parse("{% if #{markup} %} YES {% endif %}")
      end
    end
  end

  def test_no_error_on_lax_empty_filter
    assert Template.parse("{{test |a|b|}}", :error_mode => :lax)
    assert Template.parse("{{test}}", :error_mode => :lax)
    assert Template.parse("{{|test|}}", :error_mode => :lax)
  end

  def test_meaningless_parens_lax
    with_error_mode(:lax) do
      assigns = {'b' => 'bar', 'c' => 'baz'}
      markup = "a == 'foo' or (b == 'bar' and c == 'baz') or false"
      assert_template_result(' YES ',"{% if #{markup} %} YES {% endif %}", assigns)
    end
  end

  def test_unexpected_characters_silently_eat_logic_lax
    with_error_mode(:lax) do
      markup = "true && false"
      assert_template_result(' YES ',"{% if #{markup} %} YES {% endif %}")
      markup = "false || true"
      assert_template_result('',"{% if #{markup} %} YES {% endif %}")
    end
  end
end # ParsingQuirksTest
