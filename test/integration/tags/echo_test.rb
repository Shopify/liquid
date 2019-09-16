# frozen_string_literal: true

require 'test_helper'

class EchoTest < Minitest::Test
  include Liquid

  def test_echo_outputs_its_input
    assert_template_result('BAR', <<~LIQUID, 'variable-name' => 'bar')
      {%- echo variable-name | upcase -%}
    LIQUID
  end
end
