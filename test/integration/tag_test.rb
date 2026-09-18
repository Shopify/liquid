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

  def test_custom_tags_stringify_render_result_for_backwards_compatibility
    integer_tag = Class.new(Tag) do
      def render(*)
        49
      end
    end

    with_custom_tag('blabla', integer_tag) do
      template = Liquid::Template.parse("{% blabla %}")

      assert_equal('49', template.render)
    end

    array_tag = Class.new(Tag) do
      def render(*)
        [4, 9]
      end
    end

    with_custom_tag('blabla', array_tag) do
      template = Liquid::Template.parse("{% blabla %}")

      assert_equal('49', template.render)
    end
  end
end
