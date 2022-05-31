# frozen_string_literal: true

require 'test_helper'

class InlineCommentTest < Minitest::Test
  include Liquid

  def test_inline_comment_returns_nothing
    assert_template_result('', '{%- # this is an inline comment -%}')
    assert_template_result('', '{%-# this is an inline comment -%}')
    assert_template_result('', '{% # this is an inline comment %}')
    assert_template_result('', '{%# this is an inline comment %}')
  end

  def test_inline_comment_does_not_require_a_space_after_the_pound_sign
    assert_template_result('', '{%#this is an inline comment%}')
  end

  def test_liquid_inline_comment_returns_nothing
    assert_template_result('Hey there, how are you doing today?', <<~LIQUID)
      {%- liquid
        # This is how you'd write a block comment in a liquid tag.
        # It looks a lot like what you'd have in ruby.

        # You can use it as inline documentation in your
        # liquid blocks to explain why you're doing something.
        echo "Hey there, "

        # It won't affect the output.
        echo "how are you doing today?"
      -%}
    LIQUID
  end

  def test_inline_comment_can_be_written_on_multiple_lines
    assert_template_result('', <<~LIQUID)
      {%-
        # That kind of block comment is also allowed.
        # It would only be a stylistic difference.

        # Much like JavaScript's /* */ comments and their
        # leading * on new lines.
      -%}
    LIQUID
  end

  def test_inline_comment_multiple_pound_signs
    assert_template_result('', <<~LIQUID)
      {%- liquid
        ######################################
        # We support comments like this too. #
        ######################################
      -%}
    LIQUID
  end

  def test_inline_comments_require_the_pound_sign_on_every_new_line
    assert_match_syntax_error("Each line of comments must be prefixed by the '#' character", <<~LIQUID)
      {%-
        # some comment
        echo 'hello world'
      -%}
    LIQUID
  end

  def test_inline_comment_does_not_support_nested_tags
    assert_template_result(' -%}', "{%- # {% echo 'hello world' %} -%}")
  end
end
