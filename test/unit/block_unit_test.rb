# frozen_string_literal: true

require 'test_helper'

class BlockUnitTest < Minitest::Test
  include Liquid5

  def test_blankspace
    template = Liquid5::Template.parse("  ")
    assert_equal(["  "], template.root.nodelist)
  end

  def test_variable_beginning
    template = Liquid5::Template.parse("{{funk}}  ")
    assert_equal(2, template.root.nodelist.size)
    assert_equal(Variable, template.root.nodelist[0].class)
    assert_equal(String, template.root.nodelist[1].class)
  end

  def test_variable_end
    template = Liquid5::Template.parse("  {{funk}}")
    assert_equal(2, template.root.nodelist.size)
    assert_equal(String, template.root.nodelist[0].class)
    assert_equal(Variable, template.root.nodelist[1].class)
  end

  def test_variable_middle
    template = Liquid5::Template.parse("  {{funk}}  ")
    assert_equal(3, template.root.nodelist.size)
    assert_equal(String, template.root.nodelist[0].class)
    assert_equal(Variable, template.root.nodelist[1].class)
    assert_equal(String, template.root.nodelist[2].class)
  end

  def test_variable_many_embedded_fragments
    template = Liquid5::Template.parse("  {{funk}} {{so}} {{brother}} ")
    assert_equal(7, template.root.nodelist.size)
    assert_equal([String, Variable, String, Variable, String, Variable, String],
      block_types(template.root.nodelist))
  end

  def test_with_block
    template = Liquid5::Template.parse("  {% comment %} {% endcomment %} ")
    assert_equal([String, Comment, String], block_types(template.root.nodelist))
    assert_equal(3, template.root.nodelist.size)
  end

  private

  def block_types(nodelist)
    nodelist.collect(&:class)
  end
end
