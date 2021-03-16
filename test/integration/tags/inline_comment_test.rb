# frozen_string_literal: true

require 'test_helper'

class InlineCommentTest < Minitest::Test
  include Liquid

  def test_tag_in_different_styles
    assert_template_result('', '{% # This text gets ignored %}')
    assert_template_result('', '{%# This text gets ignored #%}')
    assert_template_result('', '{%# This text gets ignored %}')
    assert_template_result('', '{%#- This text gets ignored -#%}')
  end

  def test_test_syntax_error
    assert_template_result('fail', '{% #This doesnt work %}')

    assert false 
  rescue 
    # ok good
  end

  def test_tag_ws_stripping
    assert_template_result('', '   {%#- This text gets ignored -#%}    ')
  end

  def test_comment_inline_tag
    assert_template_result('ok', '{% echo "ok" # output something from a tag %}')
  end

  def test_comment_line_before_tag
    assert_template_result('ok', '{% # this sort of comment also
      echo "ok" %}')
  end

  def test_comment_inline_variable
    assert_template_result('ok', '{{ "ok" # output something from a variable }}')
    assert_template_result('ok', '{{ "OK" | downcase # output something from a variable }}')
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

  def test_multiline
    assert_template_result('', '{% # this sort of comment also
      # will just work, because it parses
      # as a single call to the "#" tag %}')   

  end

end
