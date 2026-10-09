# frozen_string_literal: true

require 'test_helper'

class IncrementTagTest < Minitest::Test
  include Liquid

  def test_inc
    assert_template_result('0 1', '{%increment port %} {{ port }}')
    assert_template_result(' 0 1 2', '{{port}} {%increment port %} {%increment port%} {{port}}')
    assert_template_result(
      '0 0 1 2 1',
      '{%increment port %} {%increment starboard%} ' \
      '{%increment port %} {%increment port%} ' \
      '{%increment starboard %}',
    )
  end

  def test_dec
    assert_template_result('-1 -1', '{%decrement port %} {{ port }}', { 'port' => 10 })
    assert_template_result(' -1 -2 -2', '{{port}} {%decrement port %} {%decrement port%} {{port}}')
    assert_template_result(
      '0 1 2 0 3 1 1 3',
      '{%increment starboard %} {%increment starboard%} {%increment starboard%} ' \
      '{%increment port %} {%increment starboard%} ' \
      '{%increment port %} {%decrement port%} ' \
      '{%decrement starboard %}',
    )
  end

  def test_increment_strict2_rejects_invalid_variable_name
    assert_raises(Liquid::SyntaxError) do
      Template.parse('{% increment foo bar %}', error_mode: :strict2)
    end
  end

  def test_increment_strict2_rejects_variable_starting_with_number
    assert_raises(Liquid::SyntaxError) do
      Template.parse('{% increment 11aa %}', error_mode: :strict2)
    end
  end

  def test_increment_strict2_accepts_valid_variable_name
    template = Template.parse('{% increment my-var %}', error_mode: :strict2)
    assert_equal('0', template.render)
  end

  def test_decrement_strict2_rejects_invalid_variable_name
    assert_raises(Liquid::SyntaxError) do
      Template.parse('{% decrement foo bar %}', error_mode: :strict2)
    end
  end

  def test_decrement_strict2_rejects_variable_starting_with_number
    assert_raises(Liquid::SyntaxError) do
      Template.parse('{% decrement 11aa %}', error_mode: :strict2)
    end
  end

  def test_decrement_strict2_accepts_valid_variable_name
    template = Template.parse('{% decrement my-var %}', error_mode: :strict2)
    assert_equal('-1', template.render)
  end

  def test_increment_strict2_rejects_empty_variable_name
    assert_raises(Liquid::SyntaxError) do
      Template.parse('{% increment %}', error_mode: :strict2)
    end
  end

  def test_decrement_strict2_rejects_empty_variable_name
    assert_raises(Liquid::SyntaxError) do
      Template.parse('{% decrement %}', error_mode: :strict2)
    end
  end
end
