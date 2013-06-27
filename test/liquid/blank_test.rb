require 'test_helper'

class BlankTest < Test::Unit::TestCase
  include Liquid
  N = 10

  def wrap_in_for(body)
    "{% for i in (1..#{N}) %}#{body}{% endfor %}"
  end

  def wrap_in_if(body)
    "{% if true %}#{body}{% endif %}"
  end

  def wrap(body)
    wrap_in_for(body) + wrap_in_if(body)
  end

  def test_loops_are_blank
    assert_template_result("", wrap_in_for(" "))
  end

  def test_if_else_are_blank
    assert_template_result("", "{% if true %} {% elsif false %} {% else %} {% endif %}")
  end

  def test_unless_is_blank
    assert_template_result("", wrap("{% unless true %} {% endunless %}"))
  end

  def test_mark_as_blank_only_during_parsing
    assert_template_result(" "*(N+1), wrap(" {% if false %} this never happens, but still, this block is not blank {% endif %}"))
  end

  def test_comments_are_blank
    assert_template_result("", wrap(" {% comment %} whatever {% endcomment %} "))
  end

  def test_captures_are_blank
    assert_template_result("", wrap(" {% capture foo %} whatever {% endcapture %} "))
  end

  def test_nested_blocks_are_blank_but_only_if_all_children_are
    assert_template_result("", wrap(wrap(" ")))
    assert_template_result("\n       but this is not "*(N+1),
      wrap(%q{{% if true %} {% comment %} this is blank {% endcomment %} {% endif %}
      {% if true %} but this is not {% endif %}}))
  end

  def test_assigns_are_blank
    assert_template_result("", wrap(' {% assign foo = "bar" %} '))
  end

  def test_whitespace_is_blank
    assert_template_result("", wrap(" "))
    assert_template_result("", wrap("\t"))
  end

  def test_whitespace_is_not_blank_if_other_stuff_is_present
    body = "     x "
    assert_template_result(body*(N+1), wrap(body))
  end

  def test_raw_is_not_blank
    assert_template_result("  "*(N+1), wrap(" {% raw %} {% endraw %}"))
  end

  def test_variables_are_not_blank
    assert_template_result("  "*(N+1), wrap(' {{ "" }} '))
    assert_template_result(" "*(N+1), wrap("{% assign foo = ' ' %}{{ foo }}"))
  end
end
