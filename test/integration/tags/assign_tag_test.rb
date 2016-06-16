require 'test_helper'

class AssignTagTest < Minitest::Test
  include Liquid

  def test_assign
    assert_template_result('monkey', "{% assign foo = 'monkey' %}{{ foo }}")
  end

  def test_string_with_end_tag
    assert_template_result("{% quoted %}", "{% assign string = '{% quoted %}' %}{{ string }}")
  end
end
