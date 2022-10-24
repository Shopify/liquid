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
    assert_template_result("<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 4 </td><td class=\"col2\"> 5 </td><td class=\"col3\"> 6 </td></tr>\n",
      '{% tablerow n in numbers cols:3%} {{n}} {% endtablerow %}',
      { 'numbers' => [1, 2, 3, 4, 5, 6] })

    assert_template_result("<tr class=\"row1\">\n</tr>\n",
      '{% tablerow n in numbers cols:3%} {{n}} {% endtablerow %}',
      { 'numbers' => [] })
  end

  def test_table_row_with_different_cols
    assert_template_result("<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td><td class=\"col4\"> 4 </td><td class=\"col5\"> 5 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 6 </td></tr>\n",
      '{% tablerow n in numbers cols:5%} {{n}} {% endtablerow %}',
      { 'numbers' => [1, 2, 3, 4, 5, 6] })
  end

  def test_table_col_counter
    assert_template_result("<tr class=\"row1\">\n<td class=\"col1\">1</td><td class=\"col2\">2</td></tr>\n<tr class=\"row2\"><td class=\"col1\">1</td><td class=\"col2\">2</td></tr>\n<tr class=\"row3\"><td class=\"col1\">1</td><td class=\"col2\">2</td></tr>\n",
      '{% tablerow n in numbers cols:2%}{{tablerowloop.col}}{% endtablerow %}',
      { 'numbers' => [1, 2, 3, 4, 5, 6] })
  end

  def test_quoted_fragment
    assert_template_result("<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 4 </td><td class=\"col2\"> 5 </td><td class=\"col3\"> 6 </td></tr>\n",
      "{% tablerow n in collections.frontpage cols:3%} {{n}} {% endtablerow %}",
      { 'collections' => { 'frontpage' => [1, 2, 3, 4, 5, 6] } })
    assert_template_result("<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 4 </td><td class=\"col2\"> 5 </td><td class=\"col3\"> 6 </td></tr>\n",
      "{% tablerow n in collections['frontpage'] cols:3%} {{n}} {% endtablerow %}",
      { 'collections' => { 'frontpage' => [1, 2, 3, 4, 5, 6] } })
  end

  def test_enumerable_drop
    assert_template_result("<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 4 </td><td class=\"col2\"> 5 </td><td class=\"col3\"> 6 </td></tr>\n",
      '{% tablerow n in numbers cols:3%} {{n}} {% endtablerow %}',
      { 'numbers' => ArrayDrop.new([1, 2, 3, 4, 5, 6]) })
  end

  def test_offset_and_limit
    assert_template_result("<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 4 </td><td class=\"col2\"> 5 </td><td class=\"col3\"> 6 </td></tr>\n",
      '{% tablerow n in numbers cols:3 offset:1 limit:6%} {{n}} {% endtablerow %}',
      { 'numbers' => [0, 1, 2, 3, 4, 5, 6, 7] })
  end

  def test_blank_string_not_iterable
    assert_template_result("<tr class=\"row1\">\n</tr>\n",
      "{% tablerow char in characters cols:3 %}I WILL NOT BE OUTPUT{% endtablerow %}",
      { 'characters' => '' })
  end

  def test_cols_nil_constant_same_as_evaluated_nil_expression
    expect = "<tr class=\"row1\">\n" \
      "<td class=\"col1\">false</td>" \
      "<td class=\"col2\">false</td>" \
      "</tr>\n"

    assert_template_result(expect,
      "{% tablerow i in (1..2) cols:nil %}{{ tablerowloop.col_last }}{% endtablerow %}")

    assert_template_result(expect,
      "{% tablerow i in (1..2) cols:var %}{{ tablerowloop.col_last }}{% endtablerow %}",
      { "var" => nil })
  end

  def test_tablerow_loop_drop_attributes
    template = <<~LIQUID.chomp
      {% tablerow i in (1...2) %}
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
end
