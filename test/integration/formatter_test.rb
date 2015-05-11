require 'test_helper'

class FormatterTest < Minitest::Test
  def assert_format(expected, src)
    with_error_mode(:lax) do
      src_ast = Liquid::Template.parse(src).root
      assert_equal expected, src_ast.format

      fmt_ast = Liquid::Template.parse(src_ast.format).root
      assert_equal expected, fmt_ast.format
    end
  end

  def test_filters
    assert_format '{{ a | b: foo, c: "foo" }}', '{{a|b:foo,c:"foo"}}'
    assert_format '{{ page.attribs.title | downcase }}', "{{page.attribs['title' ]|   downcase}}"
    assert_format '{{ page.attribs["t.i.t.l.e"] | downcase }}', "{{page.attribs['t.i.t.l.e']  | downcase }}"
    assert_format '{{ page.attribs["t&tle"] | downcase }}', "{{page.attribs['t&tle']  | downcase }}"
  end

  def test_conditionals
    src = """
      {% if true && !!%}
        cats
      {% elsif a  or  (b and  c) && d%}
        dogs
      {% endif %}

      {%unless  something%}
        cats
      {% endunless%}
    """

    expected = """
      {% if true %}
        cats
      {% elsif a or b and c %}
        dogs
      {% endif %}

      {% unless something %}
        cats
      {% endunless %}
    """

    assert_format expected, src

    src = """
      {%case  var asdf $$#$ %}
      {% when true%}
        w
      {% else%}
        e
      {%endcase  %}
    """

    expected = """
      {% case var %}
      {% when true %}
        w
      {% else %}
        e
      {% endcase %}
    """

    assert_format expected, src
  end

  def test_comments
    assert_format "{% comment %} hunter2 {% endcomment %}", "{%comment   %} hunter2 {%   endcomment ^ %}"
  end

  def test_assigns
    assert_format '{% assign foo = "monkey" %}', "{%assign foo  ='monkey' ^ %}"
  end

  def test_looping
    src = """
      {% for i in (1..10) %}
        cat
        {%ifchanged%}{{i}}{% endifchanged  %}
        {%  continue%}
      {% else %}
        dog
        {%break  %}
      {% endfor %}
    """

    expected = """
      {% for i in (1..10) %}
        cat
        {% ifchanged %}{{ i }}{% endifchanged %}
        {% continue %}
      {% else %}
        dog
        {% break %}
      {% endfor %}
    """

    assert_format expected, src

    src = "{% tablerow n in numbers cols:3  offset : 1 limit:6%} {{n}} {% endtablerow %}"
    expected = "{% tablerow n in numbers cols: 3, offset: 1, limit: 6 %} {{ n }} {% endtablerow %}"
    assert_format expected, src
  end

  def test_capture
    assert_format "{% capture foo %} foo {% endcapture %}", "{%capture  foo  %} foo {%endcapture%}"
  end

  def test_cycle
    assert_format '{% cycle "red", 2.8, "green", 1 %}', "{% cycle 'red',2.8,'green',1 %}"
  end

  def test_augment
    assert_format "{% decrement foo %}{% increment foo %}", "{%  decrement  foo%}{%increment  foo   %}"
  end

  def test_raw
    assert_format "{% raw %} foo {% endraw %}", "{%raw !!%} foo {%endraw foo%}"
  end

  def test_include
    src = <<-eof
      {% include 'foo' %}
      {% include 'foo' !!! why! %}
      {% include 'foo' with bar %}
      {% include 'foo' with bar baz: z  qux:f %}
      {% include 'foo' baz: z  qux:f %}
    eof

    expected = <<-eof
      {% include "foo" %}
      {% include "foo" %}
      {% include "foo" with bar %}
      {% include "foo" with bar baz: z, qux: f %}
      {% include "foo" baz: z, qux: f %}
    eof

    assert_format expected, src
  end

  def test_quirks
    src = <<-eof
      {% if a == 'foo' or (b == 'bar' and c == 'baz') or false %} YES {% endif %}
      {% if true && false %} YES {% endif %}
      {% if false || true %} YES {% endif %}
      {{ 'hi there' | split$$$:' ' | first }}""
      {{ 'X' | downcase) }}
      {{ 'hi there' | split:"t"" | reverse | first}}
      {{ 'hi there' | split:"t"" | remove:"i" | first}}
      {% for i in (1...5) %}{{ i }}{% endfor %}
      {{test |a|b|}}
      {{|test|}}
    eof

    expected = <<-eof
      {% if a == "foo" or b == "bar" and c == "baz" or false %} YES {% endif %}
      {% if true %} YES {% endif %}
      {% if false %} YES {% endif %}
      {{ "hi there" | split: " " | first }}""
      {{ "X" | downcase }}
      {{ "hi there" | split: "t" | reverse | first }}
      {{ "hi there" | split: "t" | first }}
      {% for i in (1..5) %}{{ i }}{% endfor %}
      {{ test | a | b }}
      {{ test }}
    eof

    assert_format expected, src
  end
end
