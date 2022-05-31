# frozen_string_literal: true

require 'test_helper'

class BlockTest < Minitest::Test
  include Liquid

  def test_unexpected_end_tag
    exc = assert_raises(SyntaxError) do
      Template.parse("{% if true %}{% endunless %}")
    end
    assert_equal(exc.message, "Liquid syntax error: 'endunless' is not a valid delimiter for if tags. use endif")
  end

  def test_with_custom_tag
    with_custom_tag('testtag', Block) do
      assert(Liquid::Template.parse("{% testtag %} {% endtesttag %}"))
    end
  end

  def test_custom_block_tags_have_a_default_render_to_output_buffer_method_for_backwards_compatibility
    klass1 = Class.new(Block) do
      def render(*)
        'hello'
      end
    end

    with_custom_tag('blabla', klass1) do
      template = Liquid::Template.parse("{% blabla %} bla {% endblabla %}")

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
      template = Liquid::Template.parse("{% blabla %} foo {% endblabla %}")

      assert_equal('foohellobar', template.render)

      buf    = +''
      output = template.render({}, output: buf)
      assert_equal('foohellobar', output)
      assert_equal('foohellobar', buf)
      assert_equal(buf.object_id, output.object_id)
    end
  end
end
