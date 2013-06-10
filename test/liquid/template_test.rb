require 'test_helper'

class TemplateContextDrop < Liquid::Drop
  def before_method(method)
    method
  end

  def foo
    'fizzbuzz'
  end

  def baz
    @context.registers['lulz']
  end
end

class TemplateTest < Test::Unit::TestCase
  include Liquid

  def test_tokenize_strings
    assert_equal [' '], Template.new.send(:tokenize, ' ')
    assert_equal ['hello world'], Template.new.send(:tokenize, 'hello world')
  end

  def test_tokenize_variables
    assert_equal ['{{funk}}'], Template.new.send(:tokenize, '{{funk}}')
    assert_equal [' ', '{{funk}}', ' '], Template.new.send(:tokenize, ' {{funk}} ')
    assert_equal [' ', '{{funk}}', ' ', '{{so}}', ' ', '{{brother}}', ' '], Template.new.send(:tokenize, ' {{funk}} {{so}} {{brother}} ')
    assert_equal [' ', '{{  funk  }}', ' '], Template.new.send(:tokenize, ' {{  funk  }} ')
  end

  def test_tokenize_blocks
    assert_equal ['{%comment%}'], Template.new.send(:tokenize, '{%comment%}')
    assert_equal [' ', '{%comment%}', ' '], Template.new.send(:tokenize, ' {%comment%} ')

    assert_equal [' ', '{%comment%}', ' ', '{%endcomment%}', ' '], Template.new.send(:tokenize, ' {%comment%} {%endcomment%} ')
    assert_equal ['  ', '{% comment %}', ' ', '{% endcomment %}', ' '], Template.new.send(:tokenize, "  {% comment %} {% endcomment %} ")
  end

  def test_instance_assigns_persist_on_same_template_object_between_parses
    t = Template.new
    assert_equal 'from instance assigns', t.parse("{% assign foo = 'from instance assigns' %}{{ foo }}").render
    assert_equal 'from instance assigns', t.parse("{{ foo }}").render
  end

  def test_instance_assigns_persist_on_same_template_parsing_between_renders
    t = Template.new.parse("{{ foo }}{% assign foo = 'foo' %}{{ foo }}")
    assert_equal 'foo', t.render
    assert_equal 'foofoo', t.render
  end

  def test_custom_assigns_do_not_persist_on_same_template
    t = Template.new
    assert_equal 'from custom assigns', t.parse("{{ foo }}").render('foo' => 'from custom assigns')
    assert_equal '', t.parse("{{ foo }}").render
  end

  def test_custom_assigns_squash_instance_assigns
    t = Template.new
    assert_equal 'from instance assigns', t.parse("{% assign foo = 'from instance assigns' %}{{ foo }}").render
    assert_equal 'from custom assigns', t.parse("{{ foo }}").render('foo' => 'from custom assigns')
  end

  def test_persistent_assigns_squash_instance_assigns
    t = Template.new
    assert_equal 'from instance assigns', t.parse("{% assign foo = 'from instance assigns' %}{{ foo }}").render
    t.assigns['foo'] = 'from persistent assigns'
    assert_equal 'from persistent assigns', t.parse("{{ foo }}").render
  end

  def test_lambda_is_called_once_from_persistent_assigns_over_multiple_parses_and_renders
    t = Template.new
    t.assigns['number'] = lambda { @global ||= 0; @global += 1 }
    assert_equal '1', t.parse("{{number}}").render
    assert_equal '1', t.parse("{{number}}").render
    assert_equal '1', t.render
    @global = nil
  end

  def test_lambda_is_called_once_from_custom_assigns_over_multiple_parses_and_renders
    t = Template.new
    assigns = {'number' => lambda { @global ||= 0; @global += 1 }}
    assert_equal '1', t.parse("{{number}}").render(assigns)
    assert_equal '1', t.parse("{{number}}").render(assigns)
    assert_equal '1', t.render(assigns)
    @global = nil
  end

  def test_resource_limits_render_length
    t = Template.parse("0123456789")
    t.resource_limits = { :render_length_limit => 5 }
    assert_equal "Liquid error: Memory limits exceeded", t.render()
    assert t.resource_limits[:reached]
    t.resource_limits = { :render_length_limit => 10 }
    assert_equal "0123456789", t.render()
    assert_not_nil t.resource_limits[:render_length_current]
  end

  def test_resource_limits_render_score
    t = Template.parse("{% for a in (1..10) %} {% for a in (1..10) %} foo {% endfor %} {% endfor %}")
    t.resource_limits = { :render_score_limit => 50 }
    assert_equal "Liquid error: Memory limits exceeded", t.render()
    assert t.resource_limits[:reached]
    t = Template.parse("{% for a in (1..100) %} foo {% endfor %}")
    t.resource_limits = { :render_score_limit => 50 }
    assert_equal "Liquid error: Memory limits exceeded", t.render()
    assert t.resource_limits[:reached]
    t.resource_limits = { :render_score_limit => 200 }
    assert_equal (" foo " * 100), t.render()
    assert_not_nil t.resource_limits[:render_score_current]
  end

  def test_resource_limits_assign_score
    t = Template.parse("{% assign foo = 42 %}{% assign bar = 23 %}")
    t.resource_limits = { :assign_score_limit => 1 }
    assert_equal "Liquid error: Memory limits exceeded", t.render()
    assert t.resource_limits[:reached]
    t.resource_limits = { :assign_score_limit => 2 }
    assert_equal "", t.render()
    assert_not_nil t.resource_limits[:assign_score_current]
  end

  def test_resource_limits_aborts_rendering_after_first_error
    t = Template.parse("{% for a in (1..100) %} foo1 {% endfor %} bar {% for a in (1..100) %} foo2 {% endfor %}")
    t.resource_limits = { :render_score_limit => 50 }
    assert_equal "Liquid error: Memory limits exceeded", t.render()
    assert t.resource_limits[:reached]
  end

  def test_resource_limits_hash_in_template_gets_updated_even_if_no_limits_are_set
    t = Template.parse("{% for a in (1..100) %} {% assign foo = 1 %} {% endfor %}")
    t.render()
    assert t.resource_limits[:assign_score_current] > 0
    assert t.resource_limits[:render_score_current] > 0
    assert t.resource_limits[:render_length_current] > 0
  end

  def test_can_use_drop_as_context
    t = Template.new
    t.registers['lulz'] = 'haha'
    drop = TemplateContextDrop.new
    assert_equal 'fizzbuzz', t.parse('{{foo}}').render(drop)
    assert_equal 'bar', t.parse('{{bar}}').render(drop)
    assert_equal 'haha', t.parse("{{baz}}").render(drop)
  end
end # TemplateTest
