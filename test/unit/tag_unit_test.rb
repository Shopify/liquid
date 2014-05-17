require 'test_helper'

class TagUnitTest < Minitest::Test
  include Liquid

  def test_tag
    tag = Tag.parse('tag', [], [], {})
    assert_equal 'liquid::tag', tag.name
    assert_equal '', tag.render(Context.new)
  end
end
