# frozen_string_literal: true

require 'test_helper'

class ParsingQuirksTest < Minitest::Test
  include Liquid

  def test_parsing_css
    text = " div { font-weight: bold; } "
    assert_equal(text, Template.parse(text).render!)
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
    assert(Template.parse("{{test}}"))

    with_error_modes(:rigid) do
      assert_raises(Liquid::SyntaxError) { Template.parse("{{|test}}") }
      assert_raises(Liquid::SyntaxError) { Template.parse("{{test |a|b|}}") }
    end
  end

  def test_meaningless_parens_error
    with_error_modes(:rigid) do
      assert_raises(SyntaxError) do
        markup = "a == 'foo' or (b == 'bar' and c == 'baz') or false"
        Template.parse("{% if #{markup} %} YES {% endif %}")
      end
    end
  end

  def test_unexpected_characters_syntax_error
    with_error_modes(:rigid) do
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

  def test_raise_on_invalid_tag_delimiter
    assert_raises(Liquid::SyntaxError) do
      Template.new.parse('{% end %}')
    end
  end

  def test_blank_variable_markup
    assert_template_result('', "{{}}")
  end

  def test_lookup_on_var_with_literal_name
    assigns = { "blank" => { "x" => "result" } }
    assert_template_result('result', "{{ blank.x }}", assigns)
    assert_template_result('result', "{{ blank['x'] }}", assigns)
  end

  def test_contains_in_id
    assert_template_result(' YES ', '{% if containsallshipments == true %} YES {% endif %}', { 'containsallshipments' => true })
  end
end # ParsingQuirksTest
