# frozen_string_literal: true

require 'test_helper'

class TokenizerTest < Minitest::Test
  def test_tokenize_strings
    assert_equal([' '], tokenize(' '))
    assert_equal(['hello world'], tokenize('hello world'))
    assert_equal(['{}'], tokenize('{}'))
  end

  def test_tokenize_variables
    assert_equal(['{{funk}}'], tokenize('{{funk}}'))
    assert_equal([' ', '{{funk}}', ' '], tokenize(' {{funk}} '))
    assert_equal([' ', '{{funk}}', ' ', '{{so}}', ' ', '{{brother}}', ' '], tokenize(' {{funk}} {{so}} {{brother}} '))
    assert_equal([' ', '{{  funk  }}', ' '], tokenize(' {{  funk  }} '))
  end

  def test_tokenize_blocks
    assert_equal(['{%comment%}'], tokenize('{%comment%}'))
    assert_equal([' ', '{%comment%}', ' '], tokenize(' {%comment%} '))

    assert_equal([' ', '{%comment%}', ' ', '{%endcomment%}', ' '], tokenize(' {%comment%} {%endcomment%} '))
    assert_equal(['  ', '{% comment %}', ' ', '{% endcomment %}', ' '], tokenize("  {% comment %} {% endcomment %} "))
  end

  def test_calculate_line_numbers_per_token_with_profiling
    assert_equal([1],       tokenize_line_numbers("{{funk}}"))
    assert_equal([1, 1, 1], tokenize_line_numbers(" {{funk}} "))
    assert_equal([1, 2, 2], tokenize_line_numbers("\n{{funk}}\n"))
    assert_equal([1, 1, 3], tokenize_line_numbers(" {{\n funk \n}} "))
  end

  def test_tokenize_with_nil_source_returns_empty_array
    assert_equal([], tokenize(nil))
  end

  def test_incomplete_curly_braces
    assert_equal(["{{.}", " "], tokenize('{{.} '))
    assert_equal(["{{}", "%}"], tokenize('{{}%}'))
    assert_equal(["{{}}", "}"], tokenize('{{}}}'))
  end

  def test_unmatching_start_and_end
    assert_equal(["{{%}"], tokenize('{{%}'))
    assert_equal(["{{%%%}}"], tokenize('{{%%%}}'))
    assert_equal(["{%", "}}"], tokenize('{%}}'))
    assert_equal(["{%%}", "}"], tokenize('{%%}}'))
  end

  def test_peek_returns_next_token_without_advancing
    tokenizer = new_tokenizer('{{a}} {{b}}')
    first = tokenizer.peek
    assert_equal('{{a}}', first)
    # peek again returns the same token (no advancement)
    assert_equal('{{a}}', tokenizer.peek)
    # shift returns the same token peek returned
    assert_equal('{{a}}', tokenizer.send(:shift))
    # now peek returns the next token
    assert_equal(' ', tokenizer.peek)
  end

  def test_peek_returns_nil_when_no_tokens_remain
    tokenizer = new_tokenizer('{{a}}')
    tokenizer.send(:shift)
    assert_nil(tokenizer.peek)
  end

  def test_position_round_trips_correctly
    tokenizer = new_tokenizer('{{a}} {{b}} {{c}}', start_line_number: 1)
    # Shift once to get past first token
    tokenizer.send(:shift)
    saved = tokenizer.position
    # Shift more tokens
    second = tokenizer.send(:shift)
    tokenizer.send(:shift)
    # Restore position
    tokenizer.position = saved
    # Shifting again returns the same second token
    assert_equal(second, tokenizer.send(:shift))
  end

  def test_position_restores_line_number
    tokenizer = new_tokenizer("hello\n{{a}}\n{{b}}", start_line_number: 1)
    saved = tokenizer.position
    assert_equal(1, tokenizer.line_number)
    tokenizer.send(:shift) # "hello\n" - line_number advances
    assert_equal(2, tokenizer.line_number)
    tokenizer.send(:shift) # "{{a}}"
    tokenizer.send(:shift) # "\n"
    # Restore to beginning
    tokenizer.position = saved
    assert_equal(1, tokenizer.line_number)
  end

  def test_matching_end_tag_finds_matching_end_tag
    tokenizer = new_tokenizer('{% render "a" %}hello{% endrender %}')
    # Shift past the opening tag token
    tokenizer.send(:shift) # {% render "a" %}
    assert(tokenizer.matching_end_tag?("render"))
  end

  def test_matching_end_tag_returns_false_when_no_match
    tokenizer = new_tokenizer('{% render "a" %}hello{{ var }}')
    tokenizer.send(:shift) # {% render "a" %}
    refute(tokenizer.matching_end_tag?("render"))
  end

  def test_matching_end_tag_handles_nested_same_name_tags
    tokenizer = new_tokenizer(
      '{% render "a" %}{% render "b" %}inner{% endrender %}outer{% endrender %}',
    )
    tokenizer.send(:shift) # {% render "a" %}
    # Should find the outer endrender (depth-aware), not the inner one
    assert(tokenizer.matching_end_tag?("render"))
  end

  def test_matching_end_tag_does_not_mutate_cursor_position
    tokenizer = new_tokenizer('{% render "a" %}hello{% endrender %}more')
    tokenizer.send(:shift) # {% render "a" %}
    saved = tokenizer.position
    tokenizer.matching_end_tag?("render")
    assert_equal(saved, tokenizer.position)
  end

  def test_matching_end_tag_returns_false_when_only_nested_end_tag
    # Only a nested endrender exists (consumed by the inner render), no outer endrender
    tokenizer = new_tokenizer(
      '{% render "a" %}{% render "b" %}{% endrender %}',
    )
    tokenizer.send(:shift) # {% render "a" %}
    # The endrender belongs to the inner render (depth 1 -> 0), not the outer (depth 0)
    refute(tokenizer.matching_end_tag?("render"))
  end

  def test_matching_end_tag_with_whitespace_control
    tokenizer = new_tokenizer('{% render "a" %}hello{%- endrender -%}')
    tokenizer.send(:shift) # {% render "a" %}
    assert(tokenizer.matching_end_tag?("render"))
  end

  def test_matching_end_tag_at_eof
    tokenizer = new_tokenizer('{% render "a" %}')
    tokenizer.send(:shift) # {% render "a" %}
    refute(tokenizer.matching_end_tag?("render"))
  end

  private

  def new_tokenizer(source, parse_context: Liquid::ParseContext.new, start_line_number: nil)
    parse_context.new_tokenizer(source, start_line_number: start_line_number)
  end

  def tokenize(source)
    tokenizer = new_tokenizer(source)
    tokens    = []
    # shift is private in Liquid::C::Tokenizer, since it is only for unit testing
    while (t = tokenizer.send(:shift))
      tokens << t
    end
    tokens
  end

  def tokenize_line_numbers(source)
    tokenizer    = new_tokenizer(source, start_line_number: 1)
    line_numbers = []
    loop do
      line_number = tokenizer.line_number
      if tokenizer.send(:shift)
        line_numbers << line_number
      else
        break
      end
    end
    line_numbers
  end
end
