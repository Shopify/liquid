# frozen_string_literal: true

require 'test_helper'

class IncrementTagTest < Minitest::Test
  include Liquid

  def test_inc
    assert_template_result('0 1', '{%increment port %} {{ port }}')
    assert_template_result(' 0 1 2', '{{port}} {%increment port %} {%increment port%} {{port}}')
    assert_template_result('0 0 1 2 1',
      '{%increment port %} {%increment starboard%} ' \
      '{%increment port %} {%increment port%} ' \
      '{%increment starboard %}')
  end

  def test_dec
    assert_template_result('-1 -1', '{%decrement port %} {{ port }}', { 'port' => 10 })
    assert_template_result(' -1 -2 -2', '{{port}} {%decrement port %} {%decrement port%} {{port}}')
    assert_template_result('0 1 2 0 3 1 1 3',
      '{%increment starboard %} {%increment starboard%} {%increment starboard%} ' \
      '{%increment port %} {%increment starboard%} ' \
      '{%increment port %} {%decrement port%} ' \
      '{%decrement starboard %}')
  end
end
