require 'test_helper'

class LiteralTagTest < Test::Unit::TestCase
  include Liquid

  def test_empty_literal
    assert_template_result '', '{% literal %}{% endliteral %}'
    assert_template_result '', '{{{}}}'
  end

  def test_simple_literal_value
    assert_template_result 'howdy',
                           '{% literal %}howdy{% endliteral %}'
  end

  def test_literals_ignore_liquid_markup
    expected = %({% if 'gnomeslab' contain 'liquid' %}yes{ % endif %})
    template = %({% literal %}#{expected}{% endliteral %})

    assert_template_result expected, template
  end

  def test_shorthand_syntax
    expected = %({% if 'gnomeslab' contain 'liquid' %}yes{ % endif %})
    template = %({{{#{expected}}}})

    assert_template_result expected, template
  end

  # Class methods
  def test_from_shorthand
    assert_equal '{% literal %}gnomeslab{% endliteral %}', Liquid::Literal.from_shorthand('{{{gnomeslab}}}')
  end

  def test_from_shorthand_ignores_improper_syntax
    text = "{% if 'hi' == 'hi' %}hi{% endif %}"
    assert_equal text, Liquid::Literal.from_shorthand(text)
  end
end # AssignTest