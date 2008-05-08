require File.dirname(__FILE__) + '/helper'

class HtmlTagTest < Test::Unit::TestCase
  include Liquid
  
  def test_html_table
    
    assert_template_result("<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 4 </td><td class=\"col2\"> 5 </td><td class=\"col3\"> 6 </td></tr>\n",
                           '{% tablerow n in numbers cols:3%} {{n}} {% endtablerow %}', 
                           'numbers' => [1,2,3,4,5,6])

    assert_template_result("<tr class=\"row1\">\n</tr>\n",
                            '{% tablerow n in numbers cols:3%} {{n}} {% endtablerow %}', 
                            'numbers' => [])
  end
  
  def test_html_table_with_different_cols
    assert_template_result("<tr class=\"row1\">\n<td class=\"col1\"> 1 </td><td class=\"col2\"> 2 </td><td class=\"col3\"> 3 </td><td class=\"col4\"> 4 </td><td class=\"col5\"> 5 </td></tr>\n<tr class=\"row2\"><td class=\"col1\"> 6 </td></tr>\n",
                           '{% tablerow n in numbers cols:5%} {{n}} {% endtablerow %}', 
                           'numbers' => [1,2,3,4,5,6])
    
  end
  
  def test_html_col_counter
    assert_template_result("<tr class=\"row1\">\n<td class=\"col1\">1</td><td class=\"col2\">2</td></tr>\n<tr class=\"row2\"><td class=\"col1\">1</td><td class=\"col2\">2</td></tr>\n<tr class=\"row3\"><td class=\"col1\">1</td><td class=\"col2\">2</td></tr>\n",
                           '{% tablerow n in numbers cols:2%}{{tablerowloop.col}}{% endtablerow %}', 
                           'numbers' => [1,2,3,4,5,6])
    
  end
  
end
