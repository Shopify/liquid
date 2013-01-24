require 'test_helper'

class ParsingQuirksTest < Test::Unit::TestCase
  include Liquid

  def test_error_with_css
    text = %| div { font-weight: bold; } |
    template = Template.parse(text)

    assert_equal text, template.render
    assert_equal [String], template.root.nodelist.collect {|i| i.class}
  end

  def test_raise_on_single_close_bracet
    assert_raise(SyntaxError) do
      Template.parse("text {{method} oh nos!")
    end
  end

  def test_raise_on_label_and_no_close_bracets
    assert_raise(SyntaxError) do
      Template.parse("TEST {{ ")
    end
  end

  def test_raise_on_label_and_no_close_bracets_percent
    assert_raise(SyntaxError) do
      Template.parse("TEST {% ")
    end
  end

  def test_error_on_empty_filter
    assert_nothing_raised do
      Template.parse("{{test |a|b|}}")
      Template.parse("{{test}}")
      Template.parse("{{|test|}}")
    end
  end

  def test_meaningless_parens
    assigns = {'b' => 'bar', 'c' => 'baz'}
    markup = "a == 'foo' or (b == 'bar' and c == 'baz') or false"
    assert_template_result(' YES ',"{% if #{markup} %} YES {% endif %}", assigns)
  end

  def test_unexpected_characters_silently_eat_logic
    markup = "true && false"
    assert_template_result(' YES ',"{% if #{markup} %} YES {% endif %}")
    markup = "false || true"
    assert_template_result('',"{% if #{markup} %} YES {% endif %}")
  end

  def test_error_on_variables_containing_curly_bracket
    assert_nothing_raised do
      Template.parse("{{ '{test}' }}")
    end
  end

  def test_variables_containing_single_curly_bracket
    text = '{test}'

    template = ''
    assert_nothing_raised do
      template = Template.parse("{{ '#{text}' }}")
    end

    assert_equal text, template.render
  end

  def test_variables_containing_double_curly_bracket

    text = "{\"foo\":{\"bar\":\"rab\"}}"
    template = ''
    assert_nothing_raised do
      template = Template.parse("{{ '#{text}' }}")
    end

    assert_equal text, template.render


    text = "{{fancy{{\\'user\\'}}name}}"
    template = ''
    assert_nothing_raised do
      template = Template.parse("{{ '#{text}' | remove:'{{just{{CurlyBrackets}}Again}}' }}")
    end

    assert_equal text, template.render
  end

  def test_variables_with_escaped_quotes
    text = 'test \" escaping'
    template = Template.parse("{{ \"#{text}\" }}")

    assert_equal text, template.render

    text = 'test \\\' escaping'
    template = Template.parse("{{ '#{text}' }}")

    assert_equal text, template.render
  end

end # ParsingQuirksTest
