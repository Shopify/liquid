require 'test_helper'

class StandardTagTest < Test::Unit::TestCase
  include Liquid

  def test_tag
    tag = Tag.new('tag', [], [])
    assert_equal 'liquid::tag', tag.name
    assert_equal '', tag.render(Context.new)
  end

  def test_no_transform
    assert_template_result('this text should come out of the template without change...',
                           'this text should come out of the template without change...')

    assert_template_result('blah','blah')
    assert_template_result('<blah>','<blah>')
    assert_template_result('|,.:','|,.:')
    assert_template_result('','')

    text = %|this shouldnt see any transformation either but has multiple lines
              as you can clearly see here ...|
    assert_template_result(text,text)
  end

  def test_has_a_block_which_does_nothing
    assert_template_result(%|the comment block should be removed  .. right?|,
                           %|the comment block should be removed {%comment%} be gone.. {%endcomment%} .. right?|)

    assert_template_result('','{%comment%}{%endcomment%}')
    assert_template_result('','{%comment%}{% endcomment %}')
    assert_template_result('','{% comment %}{%endcomment%}')
    assert_template_result('','{% comment %}{% endcomment %}')
    assert_template_result('','{%comment%}comment{%endcomment%}')
    assert_template_result('','{% comment %}comment{% endcomment %}')

    assert_template_result('foobar','foo{%comment%}comment{%endcomment%}bar')
    assert_template_result('foobar','foo{% comment %}comment{% endcomment %}bar')
    assert_template_result('foobar','foo{%comment%} comment {%endcomment%}bar')
    assert_template_result('foobar','foo{% comment %} comment {% endcomment %}bar')

    assert_template_result('foo  bar','foo {%comment%} {%endcomment%} bar')
    assert_template_result('foo  bar','foo {%comment%}comment{%endcomment%} bar')
    assert_template_result('foo  bar','foo {%comment%} comment {%endcomment%} bar')

    assert_template_result('foobar','foo{%comment%}
                                     {%endcomment%}bar')
  end

  def test_for
    assert_template_result(' yo  yo  yo  yo ','{%for item in array%} yo {%endfor%}','array' => [1,2,3,4])
    assert_template_result('yoyo','{%for item in array%}yo{%endfor%}','array' => [1,2])
    assert_template_result(' yo ','{%for item in array%} yo {%endfor%}','array' => [1])
    assert_template_result('','{%for item in array%}{%endfor%}','array' => [1,2])
    expected = <<HERE

  yo

  yo

  yo

HERE
    template = <<HERE
{%for item in array%}
  yo
{%endfor%}
HERE
    assert_template_result(expected,template,'array' => [1,2,3])
  end

  def test_for_with_range
    assert_template_result(' 1  2  3 ','{%for item in (1..3) %} {{item}} {%endfor%}')
  end

  def test_for_with_variable
    assert_template_result(' 1  2  3 ','{%for item in array%} {{item}} {%endfor%}','array' => [1,2,3])
    assert_template_result('123','{%for item in array%}{{item}}{%endfor%}','array' => [1,2,3])
    assert_template_result('123','{% for item in array %}{{item}}{% endfor %}','array' => [1,2,3])
    assert_template_result('abcd','{%for item in array%}{{item}}{%endfor%}','array' => ['a','b','c','d'])
    assert_template_result('a b c','{%for item in array%}{{item}}{%endfor%}','array' => ['a',' ','b',' ','c'])
    assert_template_result('abc','{%for item in array%}{{item}}{%endfor%}','array' => ['a','','b','','c'])
  end

  def test_for_helpers
    assigns = {'array' => [1,2,3] }
    assert_template_result(' 1/3  2/3  3/3 ',
                           '{%for item in array%} {{forloop.index}}/{{forloop.length}} {%endfor%}',
                           assigns)
    assert_template_result(' 1  2  3 ', '{%for item in array%} {{forloop.index}} {%endfor%}', assigns)
    assert_template_result(' 0  1  2 ', '{%for item in array%} {{forloop.index0}} {%endfor%}', assigns)
    assert_template_result(' 2  1  0 ', '{%for item in array%} {{forloop.rindex0}} {%endfor%}', assigns)
    assert_template_result(' 3  2  1 ', '{%for item in array%} {{forloop.rindex}} {%endfor%}', assigns)
    assert_template_result(' true  false  false ', '{%for item in array%} {{forloop.first}} {%endfor%}', assigns)
    assert_template_result(' false  false  true ', '{%for item in array%} {{forloop.last}} {%endfor%}', assigns)
  end

  def test_for_and_if
    assigns = {'array' => [1,2,3] }
    assert_template_result('+--',
                           '{%for item in array%}{% if forloop.first %}+{% else %}-{% endif %}{%endfor%}',
                           assigns)
  end

  def test_limiting
    assigns = {'array' => [1,2,3,4,5,6,7,8,9,0]}
    assert_template_result('12', '{%for i in array limit:2 %}{{ i }}{%endfor%}', assigns)
    assert_template_result('1234', '{%for i in array limit:4 %}{{ i }}{%endfor%}', assigns)
    assert_template_result('3456', '{%for i in array limit:4 offset:2 %}{{ i }}{%endfor%}', assigns)
    assert_template_result('3456', '{%for i in array limit: 4 offset: 2 %}{{ i }}{%endfor%}', assigns)
  end

  def test_dynamic_variable_limiting
    assigns = {'array' => [1,2,3,4,5,6,7,8,9,0]}
    assigns['limit'] = 2
    assigns['offset'] = 2

    assert_template_result('34', '{%for i in array limit: limit offset: offset %}{{ i }}{%endfor%}', assigns)
  end

  def test_nested_for
    assigns = {'array' => [[1,2],[3,4],[5,6]] }
    assert_template_result('123456', '{%for item in array%}{%for i in item%}{{ i }}{%endfor%}{%endfor%}', assigns)
  end

  def test_offset_only
    assigns = {'array' => [1,2,3,4,5,6,7,8,9,0]}
    assert_template_result('890', '{%for i in array offset:7 %}{{ i }}{%endfor%}', assigns)
  end

  def test_pause_resume
    assigns = {'array' => {'items' => [1,2,3,4,5,6,7,8,9,0]}}
    markup = <<-MKUP
      {%for i in array.items limit: 3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit: 3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit: 3 %}{{i}}{%endfor%}
      MKUP
    expected = <<-XPCTD
      123
      next
      456
      next
      789
      XPCTD
    assert_template_result(expected,markup,assigns)
  end

  def test_pause_resume_limit
    assigns = {'array' => {'items' => [1,2,3,4,5,6,7,8,9,0]}}
    markup = <<-MKUP
      {%for i in array.items limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:1 %}{{i}}{%endfor%}
      MKUP
    expected = <<-XPCTD
      123
      next
      456
      next
      7
      XPCTD
    assert_template_result(expected,markup,assigns)
  end

  def test_pause_resume_BIG_limit
    assigns = {'array' => {'items' => [1,2,3,4,5,6,7,8,9,0]}}
    markup = <<-MKUP
      {%for i in array.items limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:1000 %}{{i}}{%endfor%}
      MKUP
    expected = <<-XPCTD
      123
      next
      456
      next
      7890
      XPCTD
      assert_template_result(expected,markup,assigns)
  end


  def test_pause_resume_BIG_offset
    assigns = {'array' => {'items' => [1,2,3,4,5,6,7,8,9,0]}}
    markup = %q({%for i in array.items limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:3 offset:1000 %}{{i}}{%endfor%})
    expected = %q(123
      next
      456
      next
      )
      assert_template_result(expected,markup,assigns)
  end

  def test_assign
    assigns = {'var' => 'content' }
    assert_template_result('var2:  var2:content', 'var2:{{var2}} {%assign var2 = var%} var2:{{var2}}', assigns)

  end

  def test_hyphenated_assign
    assigns = {'a-b' => '1' }
    assert_template_result('a-b:1 a-b:2', 'a-b:{{a-b}} {%assign a-b = 2 %}a-b:{{a-b}}', assigns)

  end

  def test_assign_with_colon_and_spaces
    assigns = {'var' => {'a:b c' => {'paged' => '1' }}}
    assert_template_result('var2: 1', '{%assign var2 = var["a:b c"].paged %}var2: {{var2}}', assigns)
  end

  def test_capture
    assigns = {'var' => 'content' }
    assert_template_result('content foo content foo ',
                           '{{ var2 }}{% capture var2 %}{{ var }} foo {% endcapture %}{{ var2 }}{{ var2 }}',
                           assigns)
  end

  def test_capture_detects_bad_syntax
    assert_raise(SyntaxError) do
      assert_template_result('content foo content foo ',
                             '{{ var2 }}{% capture %}{{ var }} foo {% endcapture %}{{ var2 }}{{ var2 }}',
                             {'var' => 'content' })
    end
  end

  def test_case
    assigns = {'condition' => 2 }
    assert_template_result(' its 2 ',
                           '{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}',
                           assigns)

    assigns = {'condition' => 1 }
    assert_template_result(' its 1 ',
                           '{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}',
                           assigns)

    assigns = {'condition' => 3 }
    assert_template_result('',
                           '{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}',
                           assigns)

    assigns = {'condition' => "string here" }
    assert_template_result(' hit ',
                           '{% case condition %}{% when "string here" %} hit {% endcase %}',
                           assigns)

    assigns = {'condition' => "bad string here" }
    assert_template_result('',
                           '{% case condition %}{% when "string here" %} hit {% endcase %}',\
                           assigns)
  end

  def test_case_with_else
    assigns = {'condition' => 5 }
    assert_template_result(' hit ',
                           '{% case condition %}{% when 5 %} hit {% else %} else {% endcase %}',
                           assigns)

    assigns = {'condition' => 6 }
    assert_template_result(' else ',
                           '{% case condition %}{% when 5 %} hit {% else %} else {% endcase %}',
                           assigns)

    assigns = {'condition' => 6 }
    assert_template_result(' else ',
                           '{% case condition %} {% when 5 %} hit {% else %} else {% endcase %}',
                           assigns)
  end

  def test_case_on_size
    assert_template_result('',  '{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [])
    assert_template_result('1', '{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1])
    assert_template_result('2', '{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1, 1])
    assert_template_result('',  '{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1, 1, 1])
    assert_template_result('',  '{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1, 1, 1, 1])
    assert_template_result('',  '{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1, 1, 1, 1, 1])
  end

  def test_case_on_size_with_else
    assert_template_result('else',
                           '{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}',
                           'a' => [])

    assert_template_result('1',
                           '{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}',
                           'a' => [1])

    assert_template_result('2',
                           '{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}',
                           'a' => [1, 1])

    assert_template_result('else',
                           '{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}',
                           'a' => [1, 1, 1])

    assert_template_result('else',
                           '{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}',
                           'a' => [1, 1, 1, 1])

    assert_template_result('else',
                           '{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}',
                           'a' => [1, 1, 1, 1, 1])
  end

  def test_case_on_length_with_else
    assert_template_result('else',
                           '{% case a.empty? %}{% when true %}true{% when false %}false{% else %}else{% endcase %}',
                           {})

    assert_template_result('false',
                           '{% case false %}{% when true %}true{% when false %}false{% else %}else{% endcase %}',
                           {})

    assert_template_result('true',
                           '{% case true %}{% when true %}true{% when false %}false{% else %}else{% endcase %}',
                           {})

    assert_template_result('else',
                           '{% case NULL %}{% when true %}true{% when false %}false{% else %}else{% endcase %}',
                           {})
  end

  def test_assign_from_case
    # Example from the shopify forums
    code = %q({% case collection.handle %}{% when 'menswear-jackets' %}{% assign ptitle = 'menswear' %}{% when 'menswear-t-shirts' %}{% assign ptitle = 'menswear' %}{% else %}{% assign ptitle = 'womenswear' %}{% endcase %}{{ ptitle }})
    template = Liquid::Template.parse(code)
    assert_equal "menswear",   template.render("collection" => {'handle' => 'menswear-jackets'})
    assert_equal "menswear",   template.render("collection" => {'handle' => 'menswear-t-shirts'})
    assert_equal "womenswear", template.render("collection" => {'handle' => 'x'})
    assert_equal "womenswear", template.render("collection" => {'handle' => 'y'})
    assert_equal "womenswear", template.render("collection" => {'handle' => 'z'})
  end

  def test_case_when_or
    code = '{% case condition %}{% when 1 or 2 or 3 %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}'
    assert_template_result(' its 1 or 2 or 3 ', code, {'condition' => 1 })
    assert_template_result(' its 1 or 2 or 3 ', code, {'condition' => 2 })
    assert_template_result(' its 1 or 2 or 3 ', code, {'condition' => 3 })
    assert_template_result(' its 4 ', code, {'condition' => 4 })
    assert_template_result('', code, {'condition' => 5 })

    code = '{% case condition %}{% when 1 or "string" or null %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}'
    assert_template_result(' its 1 or 2 or 3 ', code, {'condition' => 1 })
    assert_template_result(' its 1 or 2 or 3 ', code, {'condition' => 'string' })
    assert_template_result(' its 1 or 2 or 3 ', code, {'condition' => nil })
    assert_template_result('', code, {'condition' => 'something else' })
  end

  def test_case_when_comma
    code = '{% case condition %}{% when 1, 2, 3 %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}'
    assert_template_result(' its 1 or 2 or 3 ', code, {'condition' => 1 })
    assert_template_result(' its 1 or 2 or 3 ', code, {'condition' => 2 })
    assert_template_result(' its 1 or 2 or 3 ', code, {'condition' => 3 })
    assert_template_result(' its 4 ', code, {'condition' => 4 })
    assert_template_result('', code, {'condition' => 5 })

    code = '{% case condition %}{% when 1, "string", null %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}'
    assert_template_result(' its 1 or 2 or 3 ', code, {'condition' => 1 })
    assert_template_result(' its 1 or 2 or 3 ', code, {'condition' => 'string' })
    assert_template_result(' its 1 or 2 or 3 ', code, {'condition' => nil })
    assert_template_result('', code, {'condition' => 'something else' })
  end

  def test_assign
    assert_equal 'variable', Liquid::Template.parse( '{% assign a = "variable"%}{{a}}'  ).render
  end

  def test_assign_an_empty_string
    assert_equal '', Liquid::Template.parse( '{% assign a = ""%}{{a}}'  ).render
  end

  def test_assign_is_global
    assert_equal 'variable',
                 Liquid::Template.parse( '{%for i in (1..2) %}{% assign a = "variable"%}{% endfor %}{{a}}'  ).render
  end

  def test_case_detects_bad_syntax
    assert_raise(SyntaxError) do
      assert_template_result('',  '{% case false %}{% when %}true{% endcase %}', {})
    end

    assert_raise(SyntaxError) do
      assert_template_result('',  '{% case false %}{% huh %}true{% endcase %}', {})
    end

  end

  def test_cycle
    assert_template_result('one','{%cycle "one", "two"%}')
    assert_template_result('one two','{%cycle "one", "two"%} {%cycle "one", "two"%}')
    assert_template_result(' two','{%cycle "", "two"%} {%cycle "", "two"%}')

    assert_template_result('one two one','{%cycle "one", "two"%} {%cycle "one", "two"%} {%cycle "one", "two"%}')

    assert_template_result('text-align: left text-align: right',
      '{%cycle "text-align: left", "text-align: right" %} {%cycle "text-align: left", "text-align: right"%}')
  end

  def test_multiple_cycles
    assert_template_result('1 2 1 1 2 3 1',
      '{%cycle 1,2%} {%cycle 1,2%} {%cycle 1,2%} {%cycle 1,2,3%} {%cycle 1,2,3%} {%cycle 1,2,3%} {%cycle 1,2,3%}')
  end

  def test_multiple_named_cycles
    assert_template_result('one one two two one one',
      '{%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %} {%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %} {%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %}')
  end

  def test_multiple_named_cycles_with_names_from_context
    assigns = {"var1" => 1, "var2" => 2 }
    assert_template_result('one one two two one one',
      '{%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %} {%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %} {%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %}', assigns)
  end

  def test_size_of_array
    assigns = {"array" => [1,2,3,4]}
    assert_template_result('array has 4 elements', "array has {{ array.size }} elements", assigns)
  end

  def test_size_of_hash
    assigns = {"hash" => {:a => 1, :b => 2, :c=> 3, :d => 4}}
    assert_template_result('hash has 4 elements', "hash has {{ hash.size }} elements", assigns)
  end

  def test_illegal_symbols
    assert_template_result('', '{% if true == empty %}?{% endif %}', {})
    assert_template_result('', '{% if true == null %}?{% endif %}', {})
    assert_template_result('', '{% if empty == true %}?{% endif %}', {})
    assert_template_result('', '{% if null == true %}?{% endif %}', {})
  end

  def test_for_reversed
    assigns = {'array' => [ 1, 2, 3] }
    assert_template_result('321','{%for item in array reversed %}{{item}}{%endfor%}',assigns)
  end


  def test_ifchanged
    assigns = {'array' => [ 1, 1, 2, 2, 3, 3] }
    assert_template_result('123','{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}',assigns)

    assigns = {'array' => [ 1, 1, 1, 1] }
    assert_template_result('1','{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}',assigns)
  end
end # StandardTagTest
