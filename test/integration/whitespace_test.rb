# frozen_string_literal: true

require 'test_helper'
require 'timeout'

class WhitespaceTest < Minitest::Test
  include Liquid


  def test_if_0xa0_utf8_whitespace_parses_correctly
    utf8_0xa0 = "\u00A0"
    assert_template_result('one', "{% if foo ==#{utf8_0xa0}1 %}one{% endif %}", { 'foo' => IntegerDrop.new('1') })
  end

end
