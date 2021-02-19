# frozen_string_literal: true

require 'test_helper'

class InlineCommentTest < Minitest::Test
  include Liquid

  def test_tag
    assert_template_result('', '{% # This text gets ignored %}')
  end

  def test_inside_liquid_tag
    source = <<~LIQUID
      {%- liquid
        echo "before("
        # This text gets ignored
        echo ")after"
      -%}
    LIQUID
    assert_template_result('before()after', source)
  end

  def test_no_space_after_hash_symbol
    assert_template_result('', '{% #immediate text %}')
    assert_template_result('', '{% liquid #immediate text %}')
  end
end
