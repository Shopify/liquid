require 'test_helper'

class TrimTest < Test::Unit::TestCase
  include Liquid

  def test_tag
    assert_template_result("123\n", "{%if true-%}\n123\n{%endif%}")
  end

  def test_variable
    template = Liquid::Template.parse("{{funk-}}\n{{so}}")
    assert_equal 2, template.root.nodelist.size
    assert_equal 'funk', template.root.nodelist[0].name
    assert_equal 'so', template.root.nodelist[1].name
  end
end # TrimTest
