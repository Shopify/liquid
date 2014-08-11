require 'test_helper'

class AssignTest < Minitest::Test
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
      assert Template.parse("{% assign foo = ('X' | downcase) %}")
    end
  end
end # AssignTest
