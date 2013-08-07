require 'test_helper'

class BlankTestFileSystem
  def read_template_file(template_path, context)
    template_path
  end
end

def assert_stripped_template_result(expected, template, assigns = {}, message = nil)
  assert_template_result(expected, template, assigns, message, { :strip_whitespace => true })
end

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

  def test_stripping_turned_off_by_default
   assert_template_result(" "*N, wrap_in_for(" "))
   assert_template_result(" \n "*N, wrap_in_for(" \n "))
  end

  def test_loops_are_stripped
    assert_stripped_template_result("", wrap_in_for(" "))
    assert_stripped_template_result("", wrap_in_for(" \r \n \t "))
  end

  def test_if_else_are_stripped
    assert_stripped_template_result("", "{% if true %} {% elsif false %} {% else %} {% endif %}")
  end

  def test_unless_is_stripped
    assert_stripped_template_result("", wrap("{% unless false %} {% endunless %} {% unless true %} woot {% endunless %}"))
  end

  def test_comments_are_stripped
    assert_stripped_template_result("", wrap(" {% comment %} whatever {% endcomment %} "))
  end

  def test_captures_are_stripped
    assert_stripped_template_result("", wrap(" {% capture foo %} whatever {% endcapture %} "))
  end

  def test_nested_blocks_are_stripped
    assert_stripped_template_result("", wrap(" " + wrap(" ") + " "))
  end

  def test_combining_stuff_to_be_stripped_with_other_stuff
    assert_stripped_template_result("        test\n      "*(N+1), wrap(
      %q{
        test
        {% if true %} {% comment %} this is blank {% endcomment %} {% endif %}
        {% if false %} and this is empty during rendering {% endif %}
      }
      )
    )
  end

  def test_assigns_are_stripped
    assert_stripped_template_result("", wrap(' {% assign foo = "bar" %} '))
  end

  def test_whitespace_is_stripped
    assert_stripped_template_result("", wrap(" "))
    assert_stripped_template_result("", wrap("\t"))
  end

  def test_whitespace_is_not_stripped_if_other_stuff_is_present_on_the_same_line
    body = "     x "
    assert_stripped_template_result(body*(N+1), wrap(body))
  end

  def test_increment_is_not_stripped
    assert_stripped_template_result(" 0"*2*(N+1), wrap("{% assign foo = 0 %} {% increment foo %} {% decrement foo %}"))
  end

  def test_raw_is_not_stripped
    assert_stripped_template_result("  "*(N+1), wrap(" {% raw %} {% endraw %}"))
  end

  def test_include_is_stripped_if_empty
    Liquid::Template.file_system = BlankTestFileSystem.new
    assert_equal "foobar"*(N+1), Template.parse(wrap("{% include 'foobar' %}")).render()
    assert_equal " foobar "*(N+1), Template.parse(wrap("{% include ' foobar ' %}")).render()
    assert_equal "   ", Template.parse(" {% include ' ' %} ").render()
  end

  def test_case_is_stripped
    assert_stripped_template_result("", wrap(" {% assign foo = 'bar' %} {% case foo %} {% when 'bar' %} {% when 'whatever' %} {% else %} {% endcase %} "))
    assert_stripped_template_result("", wrap(" {% assign foo = 'else' %} {% case foo %} {% when 'bar' %} {% when 'whatever' %} {% else %} {% endcase %} "))
    assert_stripped_template_result("   x  "*(N+1), wrap(" {% assign foo = 'else' %} {% case foo %} {% when 'bar' %} {% when 'whatever' %} {% else %} x {% endcase %} "))
  end

  def test_remove_whitespace_from_blocks_during_rendering
    assert_stripped_template_result("", wrap(" {% if false %} this block is not marked as blank during parsing, but empty during rendering {% endif %}"))
  end

  def test_remove_whitespace_lines_mixed_in_with_non_whitespace_lines
    assert_stripped_template_result("foo\nbar\n test\n"*(N+1), wrap("foo\n\n\t\n  \nbar\n \r\n test\n"))
  end
end
