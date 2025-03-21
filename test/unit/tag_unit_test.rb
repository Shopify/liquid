# frozen_string_literal: true

require 'test_helper'

class TagUnitTest < Minitest::Test
  include Liquid

  def test_tag
    tag = Tag.parse('tag', "", new_tokenizer, ParseContext.new)
    assert_equal('liquid::tag', tag.name)
    assert_equal('', tag.render(Context.new))
  end

  def test_return_raw_text_of_tag
    tag = Tag.parse("long_tag", "param1, param2, param3", new_tokenizer, ParseContext.new)
    assert_equal("long_tag param1, param2, param3", tag.raw)
  end

  def test_tag_name_should_return_name_of_the_tag
    tag = Tag.parse("some_tag", "", new_tokenizer, ParseContext.new)
    assert_equal('some_tag', tag.tag_name)
  end

  class CustomTag < Liquid::Tag
    def render(_context); end
  end

  def test_tag_render_to_output_buffer_nil_value
    custom_tag = CustomTag.parse("some_tag", "", new_tokenizer, ParseContext.new)
    assert_equal('some string', custom_tag.render_to_output_buffer(Context.new, "some string"))
  end

  private

  def new_tokenizer
    Tokenizer.new(
      source: "",
      string_scanner: StringScanner.new(""),
    )
  end
end
