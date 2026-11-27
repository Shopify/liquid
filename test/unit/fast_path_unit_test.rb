# frozen_string_literal: true

require 'test_helper'

# Tests for the byte-walking fast paths introduced in the ByteTables optimization.
# Each fast path is tested for equivalence with the original regex-based code path
# it replaces, covering accepted inputs, rejected inputs, and boundary cases.
class FastPathUnitTest < Minitest::Test
  # ── Expression.parse_number ────────────────────────────────────────
  # Fast path: byte-walk with ByteTables::DIGIT
  # Replaces: INTEGER_REGEX, FLOAT_REGEX, StringScanner loop

  def test_parse_number_simple_integers
    assert_equal(42, Liquid::Expression.parse_number("42"))
    assert_equal(0, Liquid::Expression.parse_number("0"))
    assert_equal(999, Liquid::Expression.parse_number("999"))
  end

  def test_parse_number_negative_integers
    assert_equal(-7, Liquid::Expression.parse_number("-7"))
    assert_equal(-0, Liquid::Expression.parse_number("-0"))
    assert_equal(-123, Liquid::Expression.parse_number("-123"))
  end

  def test_parse_number_simple_floats
    assert_equal(3.14, Liquid::Expression.parse_number("3.14"))
    assert_equal(0.5, Liquid::Expression.parse_number("0.5"))
    assert_equal(-0.5, Liquid::Expression.parse_number("-0.5"))
    assert_equal(100.0, Liquid::Expression.parse_number("100.0"))
  end

  def test_parse_number_trailing_dot
    # "123." → 123.0 (truncate before dot)
    assert_equal(123.0, Liquid::Expression.parse_number("123."))
    assert_equal(0.0, Liquid::Expression.parse_number("0."))
  end

  def test_parse_number_multi_dot_floats
    # "1.2.3" → 1.2 (truncate at second dot)
    assert_equal(1.2, Liquid::Expression.parse_number("1.2.3"))
    assert_equal(1.2, Liquid::Expression.parse_number("1.2.3.4"))
    assert_equal(0.0, Liquid::Expression.parse_number("0.0.0"))
  end

  def test_parse_number_rejects_non_numeric
    assert_nil(Liquid::Expression.parse_number("hello"))
    assert_nil(Liquid::Expression.parse_number(""))
    assert_nil(Liquid::Expression.parse_number("abc123"))
    assert_nil(Liquid::Expression.parse_number(".5"))
    assert_nil(Liquid::Expression.parse_number("-.5"))
  end

  def test_parse_number_rejects_trailing_alpha_after_multi_dot
    # "1.2.3a" must be nil, not 1.2 — these are not valid numbers
    assert_nil(Liquid::Expression.parse_number("1.2.3a"))
    assert_nil(Liquid::Expression.parse_number("1.2.3.4a"))
    assert_nil(Liquid::Expression.parse_number("1.2.34a"))
    assert_nil(Liquid::Expression.parse_number("-1.2.3a"))
  end

  def test_parse_number_rejects_bare_dash
    assert_nil(Liquid::Expression.parse_number("-"))
    assert_nil(Liquid::Expression.parse_number("-a"))
  end

  # ── Expression.parse strip guard ───────────────────────────────────
  # Fast path: skip String#strip when no leading/trailing whitespace
  # Must produce identical results to unconditional .strip

  def test_parse_strips_leading_whitespace
    assert_equal(42, Liquid::Expression.parse("  42"))
    assert_equal(42, Liquid::Expression.parse("\t42"))
    assert_equal(42, Liquid::Expression.parse("\n42"))
  end

  def test_parse_strips_trailing_whitespace
    assert_equal(42, Liquid::Expression.parse("42  "))
    assert_equal(42, Liquid::Expression.parse("42\t"))
    assert_equal(42, Liquid::Expression.parse("42\n"))
  end

  def test_parse_strips_both_sides
    assert_equal(42, Liquid::Expression.parse("  42  "))
    assert_equal("hello", Liquid::Expression.parse("  'hello'  "))
  end

  def test_parse_no_strip_needed
    assert_equal(42, Liquid::Expression.parse("42"))
    assert_equal("hello", Liquid::Expression.parse("'hello'"))
    assert_equal(true, Liquid::Expression.parse("true"))
  end

  def test_parse_strips_null_bytes
    # String#strip removes \x00 — the WHITESPACE table must match
    assert_equal(true, Liquid::Expression.parse("\x00true"))
    assert_equal(true, Liquid::Expression.parse("true\x00"))
  end

  # ── VariableLookup.simple_lookup? ──────────────────────────────────
  # Fast path: regex gate for simple a.b.c chains
  # Must accept only inputs the byte-walk can handle correctly

  def test_simple_lookup_accepts_single_names
    assert(Liquid::VariableLookup.simple_lookup?("product"))
    assert(Liquid::VariableLookup.simple_lookup?("x"))
    assert(Liquid::VariableLookup.simple_lookup?("_private"))
  end

  def test_simple_lookup_accepts_dotted_chains
    assert(Liquid::VariableLookup.simple_lookup?("product.title"))
    assert(Liquid::VariableLookup.simple_lookup?("a.b.c.d"))
  end

  def test_simple_lookup_accepts_question_marks
    assert(Liquid::VariableLookup.simple_lookup?("product.available?"))
    assert(Liquid::VariableLookup.simple_lookup?("empty?"))
  end

  def test_simple_lookup_accepts_hyphens
    assert(Liquid::VariableLookup.simple_lookup?("my-var"))
    assert(Liquid::VariableLookup.simple_lookup?("my-var.some-field"))
  end

  def test_simple_lookup_rejects_brackets
    refute(Liquid::VariableLookup.simple_lookup?("product[0]"))
    refute(Liquid::VariableLookup.simple_lookup?("hash['key']"))
    refute(Liquid::VariableLookup.simple_lookup?("[0]"))
  end

  def test_simple_lookup_rejects_empty_and_malformed
    refute(Liquid::VariableLookup.simple_lookup?(""))
    refute(Liquid::VariableLookup.simple_lookup?(".leading"))
    refute(Liquid::VariableLookup.simple_lookup?("trailing."))
    refute(Liquid::VariableLookup.simple_lookup?("a..b"))
  end

  # ── VariableLookup fast path equivalence ───────────────────────────
  # The fast path must produce identical name, lookups, and command_flags
  # to the original VariableParser regex path

  def test_fast_path_simple_name
    vl = Liquid::VariableLookup.new("product")
    assert_equal("product", vl.name)
    assert_equal([], vl.lookups)
  end

  def test_fast_path_dotted_chain
    vl = Liquid::VariableLookup.new("product.title")
    assert_equal("product", vl.name)
    assert_equal(["title"], vl.lookups)
  end

  def test_fast_path_deep_chain
    vl = Liquid::VariableLookup.new("a.b.c.d")
    assert_equal("a", vl.name)
    assert_equal(["b", "c", "d"], vl.lookups)
  end

  def test_fast_path_command_methods
    vl = Liquid::VariableLookup.new("items.size")
    assert_equal("items", vl.name)
    assert_equal(["size"], vl.lookups)
    assert(vl.lookup_command?(0))

    vl2 = Liquid::VariableLookup.new("items.first")
    assert(vl2.lookup_command?(0))

    vl3 = Liquid::VariableLookup.new("items.last")
    assert(vl3.lookup_command?(0))
  end

  def test_fast_path_non_command_lookups
    vl = Liquid::VariableLookup.new("product.title")
    refute(vl.lookup_command?(0))
  end

  def test_fast_path_question_mark
    vl = Liquid::VariableLookup.new("product.available?")
    assert_equal("product", vl.name)
    assert_equal(["available?"], vl.lookups)
  end

  def test_bracket_lookup_falls_to_regex_path
    vl = Liquid::VariableLookup.new("product[0]")
    assert_equal("product", vl.name)
    assert_equal([0], vl.lookups)
  end

  # ── BlockBody.try_parse_tag_token ──────────────────────────────────
  # Fast path: byte-walk tag tokens instead of FullToken regex
  # Must produce identical [tag_name, markup, newline_count] or nil

  def test_tag_token_simple
    body = Liquid::BlockBody.new
    result = body.send(:try_parse_tag_token, "{% if x %}")
    assert_equal(["if", "x ", 0], result)
  end

  def test_tag_token_whitespace_control_leading
    body = Liquid::BlockBody.new
    result = body.send(:try_parse_tag_token, "{%- if x %}")
    assert_equal(["if", "x ", 0], result)
  end

  def test_tag_token_whitespace_control_trailing
    body = Liquid::BlockBody.new
    result = body.send(:try_parse_tag_token, "{% if x -%}")
    assert_equal(["if", "x ", 0], result)
  end

  def test_tag_token_whitespace_control_both
    body = Liquid::BlockBody.new
    result = body.send(:try_parse_tag_token, "{%- if x -%}")
    assert_equal(["if", "x ", 0], result)
  end

  def test_tag_token_no_markup
    body = Liquid::BlockBody.new
    result = body.send(:try_parse_tag_token, "{% endif %}")
    assert_equal(["endif", "", 0], result)
  end

  def test_tag_token_hash_comment
    body = Liquid::BlockBody.new
    result = body.send(:try_parse_tag_token, "{% # this is a comment %}")
    assert_equal(["#", "this is a comment ", 0], result)
  end

  def test_tag_token_with_newlines
    body = Liquid::BlockBody.new
    result = body.send(:try_parse_tag_token, "{% \n if \n x %}")
    assert_equal(["if", "x ", 2], result)
  end

  def test_tag_token_hyphenated_name_stops_at_hyphen
    # TagName = /\w+/ does not include hyphens
    body = Liquid::BlockBody.new
    result = body.send(:try_parse_tag_token, "{% my-tag markup %}")
    assert_equal("my", result[0])
  end

  def test_tag_token_complex_markup
    body = Liquid::BlockBody.new
    result = body.send(:try_parse_tag_token, "{% for item in collection reversed %}")
    assert_equal("for", result[0])
    assert_equal("item in collection reversed ", result[1])
  end

  def test_tag_token_malformed_returns_nil
    body = Liquid::BlockBody.new
    # Token too short
    assert_nil(body.send(:try_parse_tag_token, "{%"))
    # No valid tag name start (digit)
    assert_nil(body.send(:try_parse_tag_token, "{% 123 %}"))
  end
end
