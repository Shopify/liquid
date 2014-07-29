require 'test_helper'

class TokenizerTest < Minitest::Test
  def test_tokenize_strings
    assert_equal [' '], tokenize(' ')
    assert_equal ['hello world'], tokenize('hello world')
  end

  def test_tokenize_variables
    assert_equal ['{{funk}}'], tokenize('{{funk}}')
    assert_equal [' ', '{{funk}}', ' '], tokenize(' {{funk}} ')
    assert_equal [' ', '{{funk}}', ' ', '{{so}}', ' ', '{{brother}}', ' '], tokenize(' {{funk}} {{so}} {{brother}} ')
    assert_equal [' ', '{{  funk  }}', ' '], tokenize(' {{  funk  }} ')
  end

  def test_tokenize_blocks
    assert_equal ['{%comment%}'], tokenize('{%comment%}')
    assert_equal [' ', '{%comment%}', ' '], tokenize(' {%comment%} ')

    assert_equal [' ', '{%comment%}', ' ', '{%endcomment%}', ' '], tokenize(' {%comment%} {%endcomment%} ')
    assert_equal ['  ', '{% comment %}', ' ', '{% endcomment %}', ' '], tokenize("  {% comment %} {% endcomment %} ")
  end

  private

  def tokenize(source)
    Liquid::Template.new.send(:tokenize, source)
  end
end
