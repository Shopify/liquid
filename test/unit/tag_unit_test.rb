require 'test_helper'

class TagUnitTest < Minitest::Test
  include Liquid

  def test_tag
    tag = Tag.parse('tag', [], [], {})
    assert_equal 'liquid::tag', tag.name
    assert_equal '', tag.render(Context.new)
  end

  def test_return_raw_text_of_tag
    tag = Tag.parse("long_tag", "param1, param2, param3", [], {})
    assert_equal("long_tag param1, param2, param3", tag.raw)
  end
end
