require 'test_helper'

class AssignTest < Test::Unit::TestCase
  include Liquid

  def test_assigned_variable
    assert_template_result('.foo.',
                           '{% assign foo = values %}.{{ foo[0] }}.',
                           'values' => %w{foo bar baz})

    assert_template_result('.bar.',
                           '{% assign foo = values %}.{{ foo[1] }}.',
                           'values' => %w{foo bar baz})
  end

  def test_assign_with_filter
    assert_template_result('.bar.',
                           '{% assign foo = values | split: "," %}.{{ foo[1] }}.',
                           'values' => "foo,bar,baz")
  end

  def test_assign_with_filter_sort
    assert_template_result('.b.',
                           '{% assign foo = values | sort %}.{{ foo[1] }}.',
                           'values' => ['c', 'a' ,'b'])
  end

  def test_assign_with_filter_sort_by_property
    assert_template_result('.1.',
                           '{% assign foo = values | sort: "a" %}.{{ foo[1].a }}.',
                           'values' => [{"a" => 2}, {"b" => 1}, {"a" => 1}])
  end

  def test_assign_syntax_error
    assert_match_syntax_error(/assign/,
                       '{% assign foo not values %}.',
                       'values' => "foo,bar,baz")
  end
end # AssignTest
