# frozen_string_literal: true

require 'test_helper'

class ForTagUnitTest < Minitest::Test
  def test_for_nodelist
    template = Liquid::Template.parse('{% for item in items %}FOR{% endfor %}')
    assert_equal(['FOR'], template.root.nodelist[0].nodelist.map(&:nodelist).flatten)
  end

  def test_for_else_nodelist
    template = Liquid::Template.parse('{% for item in items %}FOR{% else %}ELSE{% endfor %}')
    assert_equal(['FOR', 'ELSE'], template.root.nodelist[0].nodelist.map(&:nodelist).flatten)
  end

  def test_for_string_slice_bug_usage
    template = Liquid::Template.parse("{% for x in str, offset: 1 %}{{ x }},{% endfor %}")
    assert_usage("string_slice_bug") do
      assert_equal("abc,", template.render({ "str" => "abc" }))
    end
  end

  def test_for_string_0_limit_usage
    template = Liquid::Template.parse("{% for x in str, limit: 0 %}{{ x }},{% endfor %}")
    assert_usage("string_slice_bug") do
      assert_equal("abc,", template.render({ "str" => "abc" }))
    end
  end

  def test_for_string_no_slice_usage
    template = Liquid::Template.parse("{% for x in str, offset: 0, limit: 1 %}{{ x }},{% endfor %}")
    assert_usage("string_slice_bug", times: 0) do
      assert_equal("abc,", template.render({ "str" => "abc" }))
    end
  end

  private

  def assert_usage(name, times: 1, &block)
    count = 0
    result = Liquid::Usage.stub(:increment, ->(n) { count += 1 if n == name }, &block)
    assert_equal(times, count)
    result
  end
end
