# frozen_string_literal: true

require 'test_helper'

class TagTest < Minitest::Test
  include Liquid

  def test_all_tags_with_no_parse_can_render
    Template.tags.each do |key, _tag|
      Template.tags[key].new(key, '', ParseContext.new).render(Context.new)
      assert_nil(nil)
    end
  end

  def test_all_tags_are_registered
    tags = Template.tags.map { |key, _tag| key }
    expected_tags = %w(tablerow echo if break for assign ifchanged case include continue capture decrement unless increment comment raw render cycle)
    assert_equal(expected_tags, tags)
  end
end
