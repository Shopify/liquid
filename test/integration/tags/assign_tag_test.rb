# frozen_string_literal: true

require 'test_helper'

class AssignTagTest < Minitest::Test
  include Liquid

  def test_assign
    assert_template_result('monkey', "{% assign foo = 'monkey' %}{{ foo }}")
  end

  def test_string_with_end_tag
    assert_template_result("{% quoted %}", "{% assign string = '{% quoted %}' %}{{ string }}")
  end

  def test_liquid_issue_701
    assert_template_result(" contents: _{% endraw %}_", "{% assign endraw = '{% endraw %}' %} contents: _{{endraw}}_")
  end
end
