# frozen_string_literal: true

require 'test_helper'

class TagTest < Minitest::Test
  include Liquid

  def test_custom_tags_have_a_default_render_to_output_buffer_method_for_backwards_compatibility
    klass1 = Class.new(Tag) do
      def render(*)
        'hello'
      end
    end

    with_custom_tag('blabla', klass1) do
      template = Liquid::Template.parse("{% blabla %}")

      assert_equal('hello', template.render)

      buf    = +''
      output = template.render({}, output: buf)
      assert_equal('hello', output)
      assert_equal('hello', buf)
      assert_equal(buf.object_id, output.object_id)
    end

    klass2 = Class.new(klass1) do
      def render(*)
        'foo' + super + 'bar'
      end
    end

    with_custom_tag('blabla', klass2) do
      template = Liquid::Template.parse("{% blabla %}")

      assert_equal('foohellobar', template.render)

      buf    = +''
      output = template.render({}, output: buf)
      assert_equal('foohellobar', output)
      assert_equal('foohellobar', buf)
      assert_equal(buf.object_id, output.object_id)
    end
  end

  def test_tags_can_be_overwritten_using_parse_context
    static_tag = Class.new(Tag) do
      def render(*)
        'static_tag'
      end
    end

    original_tag = Class.new(Tag) do
      def render(*)
        'original_tag'
      end
    end

    new_tag = Class.new(Tag) do
      def render(*)
        'new_tag'
      end
    end

    tags_overwrite = Liquid::Template::TagRegistry.new
    tags_overwrite['dynamic_tag'] = new_tag

    with_custom_tag('static_tag', static_tag) do
      with_custom_tag('dynamic_tag', original_tag) do
        liquid = '{% static_tag %} {% dynamic_tag %}'

        template = Liquid::Template.parse(liquid)
        assert_equal('static_tag original_tag', template.render)

        template_with_overwrite = Liquid::Template.parse(liquid, tags: tags_overwrite)
        assert_equal('static_tag new_tag', template_with_overwrite.render)
      end
    end
  end
end
