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

  def test_unterminated_variables_and_tags
    assert_equal(["{{"], tokenize("{{ x"))
    assert_equal(["{{ x}", "a}}"], tokenize("{{ x}a}}"))
    assert_equal(["{%", " x"], tokenize("{% x"))
    assert_equal(["{{{x}}"], tokenize("{{{x}}"))
    assert_equal(["a", "{{%b%}"], tokenize("a{{%b%}"))
  end

  def test_tag_start_inside_variable
    assert_equal(["{{ x {% y %}", " z"], tokenize("{{ x {% y %} z"))
    assert_equal(["{{ x {%", " y z"], tokenize("{{ x {% y z"))
  end

  def test_multibyte_characters_next_to_delimiters
    assert_equal(["日本", "{{é}}", "Ø", "{%😀%}", "{é}"], tokenize("日本{{é}}Ø{%😀%}{é}"))
  end

  def test_binary_source
    source = "\xFF{{ x }}\xFE".b
    tokens = tokenize(source)

    assert_equal(["\xFF".b, "{{ x }}".b, "\xFE".b], tokens)
    assert(tokens.all? { |t| t.encoding == Encoding::BINARY })
  end

  def test_invalid_byte_sequence_in_text
    error = assert_raises(Liquid::SyntaxError) { tokenize("{{ x }} a\xFF") }
    assert_equal("Liquid syntax error: Invalid byte sequence in UTF-8", error.message)
  end

  def test_invalid_byte_sequence_in_tag
    error = assert_raises(::ArgumentError) { tokenize("{% x \xFF %}") }
    assert_equal("invalid byte sequence in UTF-8", error.message)
  end

  def test_variable_with_invalid_byte_sequence
    assert_equal(["{{ x\xFF }}".b.force_encoding(Encoding::UTF_8)], tokenize("{{ x\xFF }}"))
  end

  def test_ascii_incompatible_source
    assert_raises(Encoding::CompatibilityError) { tokenize("a {{ x }}".encode(Encoding::UTF_16LE)) }
  end

  def test_ascii_incompatible_source_after_a_variable_that_ends_inside_a_character
    error = assert_raises(Encoding::CompatibilityError) { tokenize("{{\u7B7B}a".encode(Encoding::UTF_16LE)) }
    assert_equal("incompatible encoding regexp match (US-ASCII regexp with UTF-16LE string)", error.message)
  end

  def test_shift_jis_source
    source = "表{{ x }}".encode(Encoding::Shift_JIS)
    tokens = tokenize(source)

    assert_equal(["表", "{{ x }}"].map { |t| t.encode(Encoding::Shift_JIS) }, tokens)
  end

  def test_shift_jis_characters_whose_second_byte_is_a_curly_brace
    source = "＋{{ ± }}＋{%".encode(Encoding::Shift_JIS)
    tokens = tokenize(source)

    assert_equal(["＋", "{{ ±", " }}＋", "{%"].map { |t| t.encode(Encoding::Shift_JIS) }, tokens)
  end

  def test_string_scanner_keyword_is_accepted
    require "strscan"
    tokenizer = Liquid::Tokenizer.new(source: "a{{b}}", string_scanner: StringScanner.new(""))

    assert_equal("a", tokenizer.shift)
    assert_equal("{{b}}", tokenizer.shift)
    assert_nil(tokenizer.shift)
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
