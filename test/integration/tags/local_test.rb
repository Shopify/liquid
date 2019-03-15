require 'test_helper'

class LocalTest < Minitest::Test
  include Liquid

  def test_local_is_scope_aware
    assert_template_result('value', <<~LIQUID)
      {%- if true -%}
        {%- local variable-name = 'value' -%}
        {{- variable-name -}}
      {%- endif -%}
      {{- variable-name -}}
    LIQUID
  end
end
