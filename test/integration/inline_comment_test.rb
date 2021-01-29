# frozen_string_literal: true

require 'test_helper'

class InlineCommentTest < Minitest::Test
  include Liquid

  def test_basic_usage
    template_source = <<-END_TEMPLATE
    foo{% -- this is a comment %}bar
    END_TEMPLATE
    template        = Template.parse(template_source)
    rendered        = template.render!
    assert_equal("foobar", rendered.strip)
  end
end

