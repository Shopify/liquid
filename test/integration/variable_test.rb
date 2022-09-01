# frozen_string_literal: true

require 'test_helper'

class VariableTest < Minitest::Test
  include Liquid

  def test_simple_variable
    assert_template_result('worked', "{{test}}", { 'test' => 'worked' })
    assert_template_result('worked wonderfully', "{{test}}", { 'test' => 'worked wonderfully' })
  end

  def test_variable_render_calls_to_liquid
    assert_template_result('foobar', '{{ foo }}', { 'foo' => ThingWithToLiquid.new })
  end

  def test_variable_lookup_calls_to_liquid_value
    assert_template_result('1', '{{ foo }}', { 'foo' => IntegerDrop.new('1') })
    assert_template_result('2', '{{ list[foo] }}', { 'foo' => IntegerDrop.new('1'), 'list' => [1, 2, 3] })
    assert_template_result('one', '{{ list[foo] }}', { 'foo' => IntegerDrop.new('1'), 'list' => { 1 => 'one' } })
    assert_template_result('Yay', '{{ foo }}', { 'foo' => BooleanDrop.new(true) })
    assert_template_result('YAY', '{{ foo | upcase }}', { 'foo' => BooleanDrop.new(true) })
  end

  def test_if_tag_calls_to_liquid_value
    assert_template_result('one', '{% if foo == 1 %}one{% endif %}', { 'foo' => IntegerDrop.new('1') })
    assert_template_result('one', '{% if 0 < foo %}one{% endif %}', { 'foo' => IntegerDrop.new('1') })
    assert_template_result('one', '{% if foo > 0 %}one{% endif %}', { 'foo' => IntegerDrop.new('1') })
    assert_template_result('true', '{% if foo == true %}true{% endif %}', { 'foo' => BooleanDrop.new(true) })
    assert_template_result('true', '{% if foo %}true{% endif %}', { 'foo' => BooleanDrop.new(true) })

    assert_template_result('', '{% if foo %}true{% endif %}', { 'foo' => BooleanDrop.new(false) })
    assert_template_result('', '{% if foo == true %}True{% endif %}', { 'foo' => BooleanDrop.new(false) })
  end

  def test_unless_tag_calls_to_liquid_value
    assert_template_result('', '{% unless foo %}true{% endunless %}', { 'foo' => BooleanDrop.new(true) })
  end

  def test_case_tag_calls_to_liquid_value
    assert_template_result('One', '{% case foo %}{% when 1 %}One{% endcase %}', { 'foo' => IntegerDrop.new('1') })
  end

  def test_simple_with_whitespaces
    assert_template_result("  worked  ", "  {{ test }}  ", { "test" => "worked" })
    assert_template_result("  worked wonderfully  ", "  {{ test }}  ", { "test" => "worked wonderfully" })
  end

  def test_expression_with_whitespace_in_square_brackets
    assert_template_result('result', "{{ a[ 'b' ] }}", { 'a' => { 'b' => 'result' } })
    assert_template_result('result', "{{ a[ [ 'b' ] ] }}", { 'b' => 'c', 'a' => { 'c' => 'result' } })
  end

  def test_ignore_unknown
    assert_template_result("", "{{ test }}")
  end

  def test_using_blank_as_variable_name
    assert_template_result("", "{% assign foo = blank %}{{ foo }}")
  end

  def test_using_empty_as_variable_name
    assert_template_result("", "{% assign foo = empty %}{{ foo }}")
  end

  def test_hash_scoping
    assert_template_result('worked', "{{ test.test }}", { 'test' => { 'test' => 'worked' } })
    assert_template_result('worked', "{{ test . test }}", { 'test' => { 'test' => 'worked' } })
  end

  def test_false_renders_as_false
    assert_template_result("false", "{{ foo }}", { 'foo' => false })
    assert_template_result("false", "{{ false }}")
  end

  def test_nil_renders_as_empty_string
    assert_template_result("", "{{ nil }}")
    assert_template_result("cat", "{{ nil | append: 'cat' }}")
  end

  def test_preset_assigns
    template                 = Template.parse(%({{ test }}))
    template.assigns['test'] = 'worked'
    assert_equal('worked', template.render!)
  end

  def test_reuse_parsed_template
    template                     = Template.parse(%({{ greeting }} {{ name }}))
    template.assigns['greeting'] = 'Goodbye'
    assert_equal('Hello Tobi', template.render!('greeting' => 'Hello', 'name' => 'Tobi'))
    assert_equal('Hello ', template.render!('greeting' => 'Hello', 'unknown' => 'Tobi'))
    assert_equal('Hello Brian', template.render!('greeting' => 'Hello', 'name' => 'Brian'))
    assert_equal('Goodbye Brian', template.render!('name' => 'Brian'))
    assert_equal({ 'greeting' => 'Goodbye' }, template.assigns)
  end

  def test_assigns_not_polluted_from_template
    template                 = Template.parse(%({{ test }}{% assign test = 'bar' %}{{ test }}))
    template.assigns['test'] = 'baz'
    assert_equal('bazbar', template.render!)
    assert_equal('bazbar', template.render!)
    assert_equal('foobar', template.render!('test' => 'foo'))
    assert_equal('bazbar', template.render!)
  end

  def test_hash_with_default_proc
    template        = Template.parse(%(Hello {{ test }}))
    assigns         = Hash.new { |_h, k| raise "Unknown variable '#{k}'" }
    assigns['test'] = 'Tobi'
    assert_equal('Hello Tobi', template.render!(assigns))
    assigns.delete('test')
    e = assert_raises(RuntimeError) do
      template.render!(assigns)
    end
    assert_equal("Unknown variable 'test'", e.message)
  end

  def test_multiline_variable
    assert_template_result("worked", "{{\ntest\n}}", { "test" => "worked" })
  end

  def test_render_symbol
    assert_template_result('bar', '{{ foo }}', { 'foo' => :bar })
  end

  def test_dynamic_find_var
    assert_template_result('bar', '{{ [key] }}', { 'key' => 'foo', 'foo' => 'bar' })
  end

  def test_raw_value_variable
    assert_template_result('bar', '{{ [key] }}', { 'key' => 'foo', 'foo' => 'bar' })
  end
end
