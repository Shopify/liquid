require 'test_helper'

class DeferredTest < Test::Unit::TestCase
  include Liquid

  def test_intermediate_renders_output_as_normal
    t = Template.new(intermediate: true)
    assert_equal 'output', t.parse('{{foo}}').render('foo' => 'output')
  end

  def test_intermediate_renders_raw_tags_again
    t = Template.new(intermediate: true)
    assert_equal '{%raw%}{{foo}}{%endraw%}', t.parse('{%raw %}{{foo}}{%endraw%}').render('foo' => 'output')
  end

  def test_deferred_values_are_preserved_in_intermediate_output
    t = Template.new(intermediate: true)
    assert_equal '{{a |b|c|}}foo', t.parse('{{a |b|c|}}{{d}}').render('a' => Liquid::Defer.new('a'), 'd' => 'foo')
  end

  def test_deferred_values_are_resolved
    t = Template.new(intermediate: true)
    act = '{% for b in a %}{{b}}{%endfor%}'
    exp = '{{tbl[1]}}'
    assert_equal exp, t.parse(act).render('a' => [Liquid::Defer.new('tbl[1]')])
  end

  def test_conditionals_render_both_sides
    t = Template.new(intermediate: true)
    act = '{%if a %}{{b}}{%else%}{{c}}{%endif%}'
    exp = '{%if val%}2{%else %}3{%endif%}'
    assert_equal exp, t.parse(act).render('b' => 2, 'c' => 3, 'a' => Liquid::Defer.new('val'))
  end

  def test_conditionals_resolve_variables
    t = Template.new(intermediate: true)
    act = '{%if a == f.d %}{{b}}{%else%}{{c}}{%endif%}'
    exp = '{%if val == 42%}2{%else %}3{%endif%}'
    assert_equal exp, t.parse(act).render('b' => 2, 'f' => {'d' => 42}, 'c' => 3, 'a' => Liquid::Defer.new('val'))
  end

  def test_conditionals_render_all_branches
    t = Template.new(intermediate: true)
    act = '{%if a and (3 == 3 or 2 > 4) %}{{b}}{%elsif a == b%}{{c}}{%else%}4{%endif%}'
    exp = '{%if (val and ((3 == 3 or 2 > 4)))%}2{%elsif val == 2%}3{%else %}4{%endif%}'
    assert_equal exp, t.parse(act).render('b' => 2, 'c' => 3, 'a' => Liquid::Defer.new('val'))
  end

  def test_unless_works_too
    t = Template.new(intermediate: true)
    act = '{%unless a and (3 == 3 or 2 > 4) %}{{b}}{%elsif 3 %}{{c}}{%else%}4{%endunless%}'
    exp = '{%unless (val and ((3 == 3 or 2 > 4)))%}2{%elsif 3%}3{%else %}4{%endunless%}'
    assert_equal exp, t.parse(act).render('b' => 2, 'c' => 3, 'a' => Liquid::Defer.new('val'))
  end

  def test_case_with_defer_in_when_works_too
    t = Template.new(intermediate: true)
    act = '{%case 2%}{%when a%}{{b}}{%when 3%}{{c}}{%else%}4{%endcase%}'
    exp = '{%case 2%}{%when val%}2{%when 3%}3{%else %}4{%endcase%}'
    assert_equal exp, t.parse(act).render('b' => 2, 'c' => 3, 'a' => Liquid::Defer.new('val'))
  end

  def test_case_behaves_similar_to_if
    t = Template.new(intermediate: true)
    act = '{%case a%}{%when b%}{{b}}{%when 3%}{{c}}{%else%}4{%endcase%}'
    exp = '{%case val%}{%when 2%}2{%when 3%}3{%else %}4{%endcase%}'
    assert_equal exp, t.parse(act).render('b' => 2, 'c' => 3, 'a' => Liquid::Defer.new('val'))
  end

  def test_capture_captures_deferred_variables
    t = Template.new(intermediate: true)
    act = '{%capture cap%}[{{b}}:{{a | f}}]{%endcapture%}({{c}}:{{cap}})'
    exp = '(3:[2:{{val | f}}])'
    assert_equal exp, t.parse(act).render('b' => 2, 'c' => 3, 'a' => Liquid::Defer.new('val'))
  end

  def test_increment_is_preseved
    t = Template.new(intermediate: true)
    act = '{%increment a%}{{a | f}}'
    exp = '{%increment val%}{{val | f}}'
    assert_equal exp, t.parse(act).render('a' => Liquid::Defer.new('val'))
  end

  def test_assignment
    t = Template.new(intermediate: true)
    act = '{%assign z = a | g%}{{z | f}}'
    exp = '{{val | g | f}}'
    assert_equal exp, t.parse(act).render('a' => Liquid::Defer.new('val'))
  end

  def test_ifchanged
    t = Template.new(intermediate: true)
    # this one is actually super difficult to get really truly right
    # with the current liquid evaluation model, but it's such a weird usecase
    # to use ifchanged on a deferred value that it's actually unlikely to ever
    # come up, I think, and the 'accidental' behaviour seems completely reasonable,
    # unless you actively try to exploit it.
    act = '{%ifchanged %}{{a}}{%endifchanged%}'
    exp = '{{val}}'
    assert_equal exp, t.parse(act).render('a' => Liquid::Defer.new('val'))
  end

end # DeferredTest
