# frozen_string_literal: true

require 'test_helper'

class BlockTest < Minitest::Test
  include Liquid

  def test_simple_end_tag
    assert_template_result('you rock', '{% if true %}you rock{% end %}')
    assert_template_result('you rock', '{% if true %}{% unless false %}you rock{% end %}{% end %}')
  end

  def test_unexpected_end_tag
    source = '{% if true %}{% endunless %}'
    assert_match_syntax_error("Liquid syntax error (line 1): 'endunless' is not a valid delimiter for if tags. use end or endif", source)
  end

  def test_end_closes_closest_open_tag
    source = '{% if true %}{% unless true %}{% end %}{% endunless %}'
    assert_match_syntax_error("Liquid syntax error (line 1): 'endunless' is not a valid delimiter for if tags. use end or endif", source)
  end

  # comments are special and can't be closed by `end`
  def test_unexpected_end_tag_comment
    source = '{% comment %}{% end %}'
    assert_match_syntax_error("Liquid syntax error (line 1): 'comment' tag was never closed", source)
  end

  # raw is special and can't be closed by `end`
  def test_unexpected_end_tag_raw
    source = '{% raw %}{% end %}'
    assert_match_syntax_error("Liquid syntax error (line 1): 'raw' tag was never closed", source)
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
