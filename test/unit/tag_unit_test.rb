require 'test_helper'

class TagUnitTest < Minitest::Test
  include Liquid

  def test_tag
    tag = Tag.parse('tag', "", Tokenizer.new(""), ParseContext.new)
    assert_equal 'liquid::tag', tag.name
    assert_equal '', tag.render(Context.new)
  end

  def test_return_raw_text_of_tag
    tag = Tag.parse("long_tag", "param1, param2, param3", Tokenizer.new(""), ParseContext.new)
    assert_equal("long_tag param1, param2, param3", tag.raw)
  end

  def test_tag_name_should_return_name_of_the_tag
    tag = Tag.parse("some_tag", "", Tokenizer.new(""), ParseContext.new)
    assert_equal 'some_tag', tag.tag_name
  end

  def test_custom_tags_have_a_default_render_to_output_buffer_method_for_backwards_compatibility
    klass1 = Class.new(Tag) do
      def render(*)
        'hello'
      end
    end

    with_custom_tag('blabla', klass1) do
      template = Liquid::Template.parse("{% blabla %}")

      assert_equal 'hello', template.render

      buf = ''
      output = template.render({}, output: buf)
      assert_equal 'hello', output
      assert_equal 'hello', buf
      assert_equal buf.object_id, output.object_id
    end

    klass2 = Class.new(klass1) do
      def render(*)
        'foo' + super + 'bar'
      end
    end

    with_custom_tag('blabla', klass2) do
      template = Liquid::Template.parse("{% blabla %}")

      assert_equal 'foohellobar', template.render

      buf = ''
      output = template.render({}, output: buf)
      assert_equal 'foohellobar', output
      assert_equal 'foohellobar', buf
      assert_equal buf.object_id, output.object_id
    end
  end
end
