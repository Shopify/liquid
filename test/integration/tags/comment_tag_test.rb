# frozen_string_literal: true

require 'test_helper'

class CommentTagTest < Minitest::Test
  include Liquid

  def test_single_line_comments_parse
    assert_template_result('Before comment', <<~LIQUID)
      Before comment
      {%- comment -%}
        Regular text comment
        Liquid in comment: {% echo 'Hi from comment' %}
      {%- endcomment -%}
    LIQUID
  end

  def test_multi_line_comments_parse
    assert_template_result('Before comment', <<~LIQUID)
      Before comment
      {%- comment -%} Regular text comment {%- endcomment -%}
      {%- comment -%} Liquid in comment: {% echo 'Hi from comment' %} {%- endcomment -%}
    LIQUID
  end
end # CommentTagTest
