# frozen_string_literal: true

require 'test_helper'

class TableRowTest < Minitest::Test
  include Liquid

  class ArrayDrop < Liquid::Drop
    include Enumerable

    def initialize(array)
      @array = array
    end

    def each(&block)
      @array.each(&block)
    end
  end

  def test_table_row
    assert_template_result(
      "<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 4 </td><td class=\"col2\"> 5 </td><td class=\"col3\"> 6 </td></tr>\n",
      '{% tablerow n in numbers cols:3%} {{n}} {% endtablerow %}',
      { 'numbers' => [1, 2, 3, 4, 5, 6] },
    )

    assert_template_result(
      "<tr class=\"row1\">\n</tr>\n",
      '{% tablerow n in numbers cols:3%} {{n}} {% endtablerow %}',
      { 'numbers' => [] },
    )
  end

  def test_table_row_with_different_cols
    assert_template_result(
      "<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td><td class=\"col4\"> 4 </td><td class=\"col5\"> 5 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 6 </td></tr>\n",
      '{% tablerow n in numbers cols:5%} {{n}} {% endtablerow %}',
      { 'numbers' => [1, 2, 3, 4, 5, 6] },
    )
  end

  def test_table_col_counter
    assert_template_result(
      "<tr class=\"row1\">\n<td class=\"col1\">1</td><td class=\"col2\">2</td></tr>\n<tr class=\"row2\"><td class=\"col1\">1</td><td class=\"col2\">2</td></tr>\n<tr class=\"row3\"><td class=\"col1\">1</td><td class=\"col2\">2</td></tr>\n",
      '{% tablerow n in numbers cols:2%}{{tablerowloop.col}}{% endtablerow %}',
      { 'numbers' => [1, 2, 3, 4, 5, 6] },
    )
  end

  def test_quoted_fragment
    assert_template_result(
      "<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 4 </td><td class=\"col2\"> 5 </td><td class=\"col3\"> 6 </td></tr>\n",
      "{% tablerow n in collections.frontpage cols:3%} {{n}} {% endtablerow %}",
      { 'collections' => { 'frontpage' => [1, 2, 3, 4, 5, 6] } },
    )
    assert_template_result(
      "<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 4 </td><td class=\"col2\"> 5 </td><td class=\"col3\"> 6 </td></tr>\n",
      "{% tablerow n in collections['frontpage'] cols:3%} {{n}} {% endtablerow %}",
      { 'collections' => { 'frontpage' => [1, 2, 3, 4, 5, 6] } },
    )
  end

  def test_enumerable_drop
    assert_template_result(
      "<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 4 </td><td class=\"col2\"> 5 </td><td class=\"col3\"> 6 </td></tr>\n",
      '{% tablerow n in numbers cols:3%} {{n}} {% endtablerow %}',
      { 'numbers' => ArrayDrop.new([1, 2, 3, 4, 5, 6]) },
    )
  end

  def test_offset_and_limit
    assert_template_result(
      "<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 4 </td><td class=\"col2\"> 5 </td><td class=\"col3\"> 6 </td></tr>\n",
      '{% tablerow n in numbers cols:3 offset:1 limit:6%} {{n}} {% endtablerow %}',
      { 'numbers' => [0, 1, 2, 3, 4, 5, 6, 7] },
    )
  end

  def test_blank_string_not_iterable
    assert_template_result(
      "<tr class=\"row1\">\n</tr>\n",
      "{% tablerow char in characters cols:3 %}I WILL NOT BE OUTPUT{% endtablerow %}",
      { 'characters' => '' },
    )
  end

  def test_cols_nil_constant_same_as_evaluated_nil_expression
    expect = "<tr class=\"row1\">\n" \
      "<td class=\"col1\">false</td>" \
      "<td class=\"col2\">false</td>" \
      "</tr>\n"

    assert_template_result(
      expect,
      "{% tablerow i in (1..2) cols:nil %}{{ tablerowloop.col_last }}{% endtablerow %}",
    )

    assert_template_result(
      expect,
      "{% tablerow i in (1..2) cols:var %}{{ tablerowloop.col_last }}{% endtablerow %}",
      { "var" => nil },
    )
  end

  def test_nil_limit_is_treated_as_zero
    expect = "<tr class=\"row1\">\n" \
      "</tr>\n"

    assert_template_result(
      expect,
      "{% tablerow i in (1..2) limit:nil %}{{ i }}{% endtablerow %}",
    )

    assert_template_result(
      expect,
      "{% tablerow i in (1..2) limit:var %}{{ i }}{% endtablerow %}",
      { "var" => nil },
    )
  end

  def test_nil_offset_is_treated_as_zero
    expect = "<tr class=\"row1\">\n" \
      "<td class=\"col1\">1:false</td>" \
      "<td class=\"col2\">2:true</td>" \
      "</tr>\n"

    assert_template_result(
      expect,
      "{% tablerow i in (1..2) offset:nil %}{{ i }}:{{ tablerowloop.col_last }}{% endtablerow %}",
    )

    assert_template_result(
      expect,
      "{% tablerow i in (1..2) offset:var %}{{ i }}:{{ tablerowloop.col_last }}{% endtablerow %}",
      { "var" => nil },
    )
  end

  def test_tablerow_loop_drop_attributes
    template = <<~LIQUID.chomp
      {% tablerow i in (1..2) %}
      col: {{ tablerowloop.col }}
      col0: {{ tablerowloop.col0 }}
      col_first: {{ tablerowloop.col_first }}
      col_last: {{ tablerowloop.col_last }}
      first: {{ tablerowloop.first }}
      index: {{ tablerowloop.index }}
      index0: {{ tablerowloop.index0 }}
      last: {{ tablerowloop.last }}
      length: {{ tablerowloop.length }}
      rindex: {{ tablerowloop.rindex }}
      rindex0: {{ tablerowloop.rindex0 }}
      row: {{ tablerowloop.row }}
      {% endtablerow %}
    LIQUID

    expected_output = <<~OUTPUT
      <tr class="row1">
      <td class="col1">
      col: 1
      col0: 0
      col_first: true
      col_last: false
      first: true
      index: 1
      index0: 0
      last: false
      length: 2
      rindex: 2
      rindex0: 1
      row: 1
      </td><td class="col2">
      col: 2
      col0: 1
      col_first: false
      col_last: true
      first: false
      index: 2
      index0: 1
      last: true
      length: 2
      rindex: 1
      rindex0: 0
      row: 1
      </td></tr>
    OUTPUT

    assert_template_result(expected_output, template)
  end

  def test_table_row_handles_interrupts
    assert_template_result(
      "<tr class=\"row1\">\n<td class=\"col1\"> 1 </td></tr>\n",
      '{% tablerow n in (1..3) cols:2 %} {{n}} {% break %} {{n}} {% endtablerow %}',
    )

    assert_template_result(
      "<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 3 </td></tr>\n",
      '{% tablerow n in (1..3) cols:2 %} {{n}} {% continue %} {{n}} {% endtablerow %}',
    )
  end

  def test_table_row_does_not_leak_interrupts
    template = <<~LIQUID
      {% for i in (1..2) -%}
      {% for j in (1..2) -%}
      {% tablerow k in (1..3) %}{% break %}{% endtablerow -%}
      loop j={{ j }}
      {% endfor -%}
      loop i={{ i }}
      {% endfor -%}
      after loop
    LIQUID

    expected = <<~STR
      <tr class="row1">
      <td class="col1"></td></tr>
      loop j=1
      <tr class="row1">
      <td class="col1"></td></tr>
      loop j=2
      loop i=1
      <tr class="row1">
      <td class="col1"></td></tr>
      loop j=1
      <tr class="row1">
      <td class="col1"></td></tr>
      loop j=2
      loop i=2
      after loop
    STR

    assert_template_result(
      expected,
      template,
    )
  end

  def test_tablerow_with_cols_attribute_in_strict2_mode
    template = <<~LIQUID.chomp
      {% tablerow i in (1..6) cols: 3 %}{{ i }}{% endtablerow %}
    LIQUID

    expected = <<~OUTPUT
      <tr class="row1">
      <td class="col1">1</td><td class="col2">2</td><td class="col3">3</td></tr>
      <tr class="row2"><td class="col1">4</td><td class="col2">5</td><td class="col3">6</td></tr>
    OUTPUT

    with_error_modes(:strict2) do
      assert_template_result(expected, template)
    end
  end

  def test_tablerow_with_limit_attribute_in_strict2_mode
    template = <<~LIQUID.chomp
      {% tablerow i in (1..10) limit: 3 %}{{ i }}{% endtablerow %}
    LIQUID

    expected = <<~OUTPUT
      <tr class="row1">
      <td class="col1">1</td><td class="col2">2</td><td class="col3">3</td></tr>
    OUTPUT

    with_error_modes(:strict2) do
      assert_template_result(expected, template)
    end
  end

  def test_tablerow_with_offset_attribute_in_strict2_mode
    template = <<~LIQUID.chomp
      {% tablerow i in (1..5) offset: 2 %}{{ i }}{% endtablerow %}
    LIQUID

    expected = <<~OUTPUT
      <tr class="row1">
      <td class="col1">3</td><td class="col2">4</td><td class="col3">5</td></tr>
    OUTPUT

    with_error_modes(:strict2) do
      assert_template_result(expected, template)
    end
  end

  def test_tablerow_with_range_attribute_in_strict2_mode
    template = <<~LIQUID.chomp
      {% tablerow i in (1..3) range: (1..10) %}{{ i }}{% endtablerow %}
    LIQUID

    expected = <<~OUTPUT
      <tr class="row1">
      <td class="col1">1</td><td class="col2">2</td><td class="col3">3</td></tr>
    OUTPUT

    with_error_modes(:strict2) do
      assert_template_result(expected, template)
    end
  end

  def test_tablerow_with_multiple_attributes_in_strict2_mode
    template = <<~LIQUID.chomp
      {% tablerow i in (1..10) cols: 2, limit: 4, offset: 1 %}{{ i }}{% endtablerow %}
    LIQUID

    expected = <<~OUTPUT
      <tr class="row1">
      <td class="col1">2</td><td class="col2">3</td></tr>
      <tr class="row2"><td class="col1">4</td><td class="col2">5</td></tr>
    OUTPUT

    with_error_modes(:strict2) do
      assert_template_result(expected, template)
    end
  end

  def test_tablerow_with_variable_collection_in_strict2_mode
    template = <<~LIQUID.chomp
      {% tablerow n in numbers cols: 2 %}{{ n }}{% endtablerow %}
    LIQUID

    expected = <<~OUTPUT
      <tr class="row1">
      <td class="col1">1</td><td class="col2">2</td></tr>
      <tr class="row2"><td class="col1">3</td><td class="col2">4</td></tr>
    OUTPUT

    with_error_modes(:strict2) do
      assert_template_result(expected, template, { 'numbers' => [1, 2, 3, 4] })
    end
  end

  def test_tablerow_with_dotted_access_in_strict2_mode
    template = <<~LIQUID.chomp
      {% tablerow n in obj.numbers cols: 2 %}{{ n }}{% endtablerow %}
    LIQUID

    expected = <<~OUTPUT
      <tr class="row1">
      <td class="col1">1</td><td class="col2">2</td></tr>
      <tr class="row2"><td class="col1">3</td><td class="col2">4</td></tr>
    OUTPUT

    with_error_modes(:strict2) do
      assert_template_result(expected, template, { 'obj' => { 'numbers' => [1, 2, 3, 4] } })
    end
  end

  def test_tablerow_with_bracketed_access_in_strict2_mode
    template = <<~LIQUID.chomp
      {% tablerow n in obj["numbers"] cols: 2 %}{{ n }}{% endtablerow %}
    LIQUID

    expected = <<~OUTPUT
      <tr class="row1">
      <td class="col1">10</td><td class="col2">20</td></tr>
    OUTPUT

    with_error_modes(:strict2) do
      assert_template_result(expected, template, { 'obj' => { 'numbers' => [10, 20] } })
    end
  end

  def test_tablerow_without_attributes_in_strict2_mode
    template = <<~LIQUID.chomp
      {% tablerow i in (1..3) %}{{ i }}{% endtablerow %}
    LIQUID

    expected = <<~OUTPUT
      <tr class="row1">
      <td class="col1">1</td><td class="col2">2</td><td class="col3">3</td></tr>
    OUTPUT

    with_error_modes(:strict2) do
      assert_template_result(expected, template)
    end
  end

  def test_tablerow_without_in_keyword_in_strict2_mode
    template = '{% tablerow i (1..10) %}{{ i }}{% endtablerow %}'

    with_error_modes(:strict2) do
      error = assert_raises(SyntaxError) { Template.parse(template) }
      assert_equal("Liquid syntax error: For loops require an 'in' clause in \"i (1..10)\"", error.message)
    end
  end

  def test_tablerow_with_multiple_invalid_attributes_reports_first_in_strict2_mode
    template = '{% tablerow i in (1..10) invalid1: 5, invalid2: 10 %}{{ i }}{% endtablerow %}'

    with_error_modes(:strict2) do
      error = assert_raises(SyntaxError) { Template.parse(template) }
      assert_equal("Liquid syntax error: Invalid attribute 'invalid1' in tablerow loop. Valid attributes are cols, limit, offset, and range in \"i in (1..10) invalid1: 5, invalid2: 10\"", error.message)
    end
  end

  def test_tablerow_with_empty_collection_in_strict2_mode
    template = <<~LIQUID.chomp
      {% tablerow i in empty_array cols: 2 %}{{ i }}{% endtablerow %}
    LIQUID

    expected = <<~OUTPUT
      <tr class="row1">
      </tr>
    OUTPUT

    with_error_modes(:strict2) do
      assert_template_result(expected, template, { 'empty_array' => [] })
    end
  end

  def test_tablerow_with_invalid_attribute_strict_vs_strict2
    template = '{% tablerow i in (1..5) invalid_attr: 10 %}{{ i }}{% endtablerow %}'

    expected = <<~OUTPUT
      <tr class="row1">
      <td class="col1">1</td><td class="col2">2</td><td class="col3">3</td><td class="col4">4</td><td class="col5">5</td></tr>
    OUTPUT

    with_error_modes(:strict2) do
      error = assert_raises(SyntaxError) { Template.parse(template) }
      assert_match(/Invalid attribute 'invalid_attr'/, error.message)
    end
  end

  def test_tablerow_with_invalid_expression_strict_vs_strict2
    template = '{% tablerow i in (1..5) limit: foo=>bar %}{{ i }}{% endtablerow %}'

    with_error_modes(:strict2) do
      error = assert_raises(SyntaxError) { Template.parse(template) }
      assert_match(/Unexpected character =/, error.message)
    end
  end
end
