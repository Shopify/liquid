require 'test_helper'

class TokenizerTest < Test::Unit::TestCase
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

  def test_tokenize_incomplete_end
    assert_tokens 'before{{ incomplete }after', ['before', '{{ incomplete }', 'after']
    assert_tokens 'before{% incomplete %after', ['before', '{%', ' incomplete %after']
  end

  def test_tokenize_no_end
    assert_tokens 'before{{ unterminated ', ['before', '{{', ' unterminated ']
    assert_tokens 'before{% unterminated ', ['before', '{%', ' unterminated ']
  end

  private

  def assert_tokens(source, expected)
    assert_equal expected, tokenize(source)
    assert_equal expected, old_tokenize(source)
  end

  def tokenize(source)
    tokenizer = Liquid::Tokenizer.new(source)
    tokens = []
    while token = tokenizer.next
      tokens << token
    end
    tokens
  end

  AnyStartingTag        = /\{\{|\{\%/
  VariableIncompleteEnd = /\}\}?/
  PartialTemplateParser = /#{Liquid::TagStart}.*?#{Liquid::TagEnd}|#{Liquid::VariableStart}.*?#{VariableIncompleteEnd}/o
  TemplateParser        = /(#{PartialTemplateParser}|#{AnyStartingTag})/o

  def old_tokenize(source)
    return [] if source.to_s.empty?
    tokens = source.split(TemplateParser)

    # removes the rogue empty element at the beginning of the array
    tokens.shift if tokens[0] and tokens[0].empty?

    tokens
  end
end
