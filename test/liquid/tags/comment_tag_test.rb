require 'test_helper'

class CommentTagTest < Test::Unit::TestCase
  include Liquid

  def test_comment
    assigns = {}
    markup = '{% comment %}This is a comment{% endcomment %}'
    expected = ''
    
    assert_template_result(expected, markup, assigns)
  end

  def test_comments_dont_eval
    assigns = {'test' => 'test'}
    markup = '{% comment %}This is a comment {{ test }}{% endcomment %}'
    expected = ''
    
    assert_template_result(expected, markup, assigns)
  end 

  def test_comment_new_format
    assert_template_result('', '{* This is a comment *}', {})
    assert_template_result('1', '{* This is a comment *}1', {})
    assert_template_result('11', '1{* This is a comment *}1', {})

    assigns = {'test' => 1}
    markup = '{% if test == 1 %}{* this means something *}1{% endif %}'
    expected = '1'

    assert_template_result(expected, markup, assigns)
  end

end
