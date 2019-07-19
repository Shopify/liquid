require 'test_helper'

class BlockUnitTest < Minitest::Test
  include Liquid

  def test_blankspace
    template = Liquid::Template.parse("  ")
    assert_equal ["  "], template.root.nodelist
  end

  def test_variable_beginning
    template = Liquid::Template.parse("{{funk}}  ")
    assert_equal 2, template.root.nodelist.size
    assert_equal Variable, template.root.nodelist[0].class
    assert_equal String, template.root.nodelist[1].class
  end

  def test_variable_end
    template = Liquid::Template.parse("  {{funk}}")
    assert_equal 2, template.root.nodelist.size
    assert_equal String, template.root.nodelist[0].class
    assert_equal Variable, template.root.nodelist[1].class
  end

  def test_variable_middle
    template = Liquid::Template.parse("  {{funk}}  ")
    assert_equal 3, template.root.nodelist.size
    assert_equal String, template.root.nodelist[0].class
    assert_equal Variable, template.root.nodelist[1].class
    assert_equal String, template.root.nodelist[2].class
  end

  def test_variable_many_embedded_fragments
    template = Liquid::Template.parse("  {{funk}} {{so}} {{brother}} ")
    assert_equal 7, template.root.nodelist.size
    assert_equal [String, Variable, String, Variable, String, Variable, String],
      block_types(template.root.nodelist)
  end

  def test_with_block
    template = Liquid::Template.parse("  {% comment %} {% endcomment %} ")
    assert_equal [String, Comment, String], block_types(template.root.nodelist)
    assert_equal 3, template.root.nodelist.size
  end

  def test_with_custom_tag
    with_custom_tag('testtag', Block) do
      assert Liquid::Template.parse("{% testtag %} {% endtesttag %}")
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
      template = Liquid::Template.parse("{% blabla %} foo {% endblabla %}")

      assert_equal 'foohellobar', template.render

      buf = ''
      output = template.render({}, output: buf)
      assert_equal 'foohellobar', output
      assert_equal 'foohellobar', buf
      assert_equal buf.object_id, output.object_id
    end
  end

  private

  def block_types(nodelist)
    nodelist.collect(&:class)
  end
end # VariableTest
