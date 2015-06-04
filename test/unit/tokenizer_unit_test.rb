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

  def test_calculate_line_numbers_per_token_with_profiling
    assert_equal [1],       tokenize("{{funk}}", true).map(&:line_number)
    assert_equal [1, 1, 1], tokenize(" {{funk}} ", true).map(&:line_number)
    assert_equal [1, 2, 2], tokenize("\n{{funk}}\n", true).map(&:line_number)
    assert_equal [1, 1, 3], tokenize(" {{\n funk \n}} ", true).map(&:line_number)
  end

  private

  def tokenize(source, line_numbers = false)
    tokenizer = Liquid::Tokenizer.new(source, line_numbers)
    tokens = []
    while t = tokenizer.shift
      tokens << t
    end
    tokens
  end
end
