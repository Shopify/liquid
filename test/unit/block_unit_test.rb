# frozen_string_literal: true

require 'test_helper'

class BlockUnitTest < Minitest::Test
  include Liquid

  def test_blankspace
    template = Liquid::Template.parse("  ")
    assert_equal(["  "], template.root.nodelist)
  end

  def test_variable_beginning
    template = Liquid::Template.parse("{{funk}}  ")
    assert_equal(2, template.root.nodelist.size)
    assert_equal(Variable, template.root.nodelist[0].class)
    assert_equal(String, template.root.nodelist[1].class)
  end

  def test_variable_end
    template = Liquid::Template.parse("  {{funk}}")
    assert_equal(2, template.root.nodelist.size)
    assert_equal(String, template.root.nodelist[0].class)
    assert_equal(Variable, template.root.nodelist[1].class)
  end

  def test_variable_middle
    template = Liquid::Template.parse("  {{funk}}  ")
    assert_equal(3, template.root.nodelist.size)
    assert_equal(String, template.root.nodelist[0].class)
    assert_equal(Variable, template.root.nodelist[1].class)
    assert_equal(String, template.root.nodelist[2].class)
  end

  def test_variable_with_multibyte_character
    template = Liquid::Template.parse("{{ '❤️' }}")
    assert_equal(1, template.root.nodelist.size)
    assert_equal(Variable, template.root.nodelist[0].class)
  end

  def test_variable_many_embedded_fragments
    template = Liquid::Template.parse("  {{funk}} {{so}} {{brother}} ")
    assert_equal(7, template.root.nodelist.size)
    assert_equal(
      [String, Variable, String, Variable, String, Variable, String],
      block_types(template.root.nodelist),
    )
  end

  def test_with_block
    template = Liquid::Template.parse("  {% comment %} {% endcomment %} ")
    assert_equal([String, Comment, String], block_types(template.root.nodelist))
    assert_equal(3, template.root.nodelist.size)
  end

  def test_remove_empty_for_blocks_with_optimization_option
    source = <<~LIQUID.chomp
      {% for i in (1..1000000) %}
      {% endfor %}
    LIQUID

    assert_root_nodelist_size(source, 0, omit_blank_nodes: true)

    source = <<~LIQUID.chomp
      {% for i in (1..1000000) %}
      {% else %}
      {% endfor %}
    LIQUID

    assert_root_nodelist_size(source, 0, omit_blank_nodes: true)

    source = <<~LIQUID.chomp
      {% for i in list %}
        i
      {% endfor %}
    LIQUID

    assert_root_nodelist_size(source, 1, omit_blank_nodes: true)

    source = <<~LIQUID.chomp
      {% for i in list %}
      {% else %}
        1
      {% endfor %}
    LIQUID

    assert_root_nodelist_size(source, 1, omit_blank_nodes: true)
  end

  def test_remove_comment_nodes_with_optimization_option
    source = <<~LIQUID.chomp
      {% comment %}
        {% if true %}
        {% endif %}
      {% endcomment %}
    LIQUID

    assert_root_nodelist_size(source, 0, omit_blank_nodes: true)

    source = <<~LIQUID.chomp
      {% liquid
        comment
          if true
          endif
        endcomment
      %}
    LIQUID

    assert_root_nodelist_size(source, 0, omit_blank_nodes: true)
  end

  def test_remove_if_nodes_with_optimization_option
    source = <<~LIQUID.chomp
      {% if true %}
      {% endif %}
    LIQUID

    assert_root_nodelist_size(source, 0, omit_blank_nodes: true)

    source = <<~LIQUID.chomp
      {% unless true %}
      {% endunless %}
    LIQUID

    assert_root_nodelist_size(source, 0, omit_blank_nodes: true)

    source = <<~LIQUID.chomp
      {% if false %}
      {% else %}
      {% endif %}
    LIQUID

    assert_root_nodelist_size(source, 0, omit_blank_nodes: true)

    source = <<~LIQUID.chomp
      {% if false %}
      {% else %}
        Hello!
      {% endif %}
    LIQUID

    assert_root_nodelist_size(source, 1, omit_blank_nodes: true)
  end

  private

  def assert_root_nodelist_size(source, expected_size, parse_options = {})
    template = Liquid::Template.parse(source, parse_options)

    assert_equal(expected_size, template.root.nodelist.size)
  end

  def block_types(nodelist)
    nodelist.collect(&:class)
  end
end
