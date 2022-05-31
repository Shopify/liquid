# frozen_string_literal: true

require 'test_helper'

class AssignTest < Minitest::Test
  include Liquid

  def test_assign_with_hyphen_in_variable_name
    template_source = <<-END_TEMPLATE
    {% assign this-thing = 'Print this-thing' %}
    {{ this-thing }}
    END_TEMPLATE
    template        = Template.parse(template_source)
    rendered        = template.render!
    assert_equal("Print this-thing", rendered.strip)
  end

  def test_assigned_variable
    assert_template_result('.foo.',
      '{% assign foo = values %}.{{ foo[0] }}.',
      'values' => %w(foo bar baz))

    assert_template_result('.bar.',
      '{% assign foo = values %}.{{ foo[1] }}.',
      'values' => %w(foo bar baz))
  end

  def test_assign_with_filter
    assert_template_result('.bar.',
      '{% assign foo = values | split: "," %}.{{ foo[1] }}.',
      'values' => "foo,bar,baz")
  end

  def test_assign_syntax_error
    assert_match_syntax_error(/assign/,
      '{% assign foo not values %}.',
      'values' => "foo,bar,baz")
  end

  def test_assign_uses_error_mode
    with_error_mode(:strict) do
      assert_raises(SyntaxError) do
        Template.parse("{% assign foo = ('X' | downcase) %}")
      end
    end
    with_error_mode(:lax) do
      assert(Template.parse("{% assign foo = ('X' | downcase) %}"))
    end
  end

  def test_expression_with_whitespace_in_square_brackets
    source = "{% assign r = a[ 'b' ] %}{{ r }}"
    assert_template_result('result', source, 'a' => { 'b' => 'result' })
  end

  def test_assign_score_exceeding_resource_limit
    t = Template.parse("{% assign foo = 42 %}{% assign bar = 23 %}")
    t.resource_limits.assign_score_limit = 1
    assert_equal("Liquid error: Memory limits exceeded", t.render)
    assert(t.resource_limits.reached?)

    t.resource_limits.assign_score_limit = 2
    assert_equal("", t.render!)
    refute_nil(t.resource_limits.assign_score)
  end

  def test_assign_score_exceeding_limit_from_composite_object
    t = Template.parse("{% assign foo = 'aaaa' | reverse %}")

    t.resource_limits.assign_score_limit = 3
    assert_equal("Liquid error: Memory limits exceeded", t.render)
    assert(t.resource_limits.reached?)

    t.resource_limits.assign_score_limit = 5
    assert_equal("", t.render!)
  end

  def test_assign_score_of_int
    assert_equal(1, assign_score_of(123))
  end

  def test_assign_score_of_string_counts_bytes
    assert_equal(3, assign_score_of('123'))
    assert_equal(5, assign_score_of('12345'))
    assert_equal(9, assign_score_of('すごい'))
  end

  def test_assign_score_of_array
    assert_equal(1, assign_score_of([]))
    assert_equal(2, assign_score_of([123]))
    assert_equal(6, assign_score_of([123, 'abcd']))
  end

  def test_assign_score_of_hash
    assert_equal(1, assign_score_of({}))
    assert_equal(5, assign_score_of('int' => 123))
    assert_equal(12, assign_score_of('int' => 123, 'str' => 'abcd'))
  end

  private

  class ObjectWrapperDrop < Liquid::Drop
    def initialize(obj)
      @obj = obj
    end

    def value
      @obj
    end
  end

  def assign_score_of(obj)
    context = Liquid::Context.new('drop' => ObjectWrapperDrop.new(obj))
    Liquid::Template.parse('{% assign obj = drop.value %}').render!(context)
    context.resource_limits.assign_score
  end
end
