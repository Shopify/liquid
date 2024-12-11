# frozen_string_literal: true

require 'test_helper'

class EagerOptimizeTest < Minitest::Test
  include Liquid

  def test_remove_empty_blocks
    source = <<~LIQUID.gsub(/\n/, '')
      {% for i in (1..1000000) %}
      {% endfor %}
    LIQUID

    template = Liquid::Template.parse(source, eager_optimize: true)
    assert_equal(0, total_node_count(template))
  end

  def test_remove_false_if_block
    source = <<~LIQUID.gsub(/\n/, '')
      {% if false %}
        {% if true %}
          {% if true %}
            {% if true %}
              {{ "Hello world!" }}
            {% endif %}
          {% endif %}
        {% endif %}
      {% endif %}
    LIQUID

    template = Liquid::Template.parse(source, eager_optimize: true)
    assert_equal(0, total_node_count(template))

    source = <<~LIQUID.gsub(/\n/, '')
      {% if false %}
        {% for i in (1..1000000) %}
          {{ "Hello world!" }}
        {% endfor %}
      {% endif %}
    LIQUID

    template = Liquid::Template.parse(source, eager_optimize: true)
    assert_equal(0, total_node_count(template))
  end

  def test_remove_multiple_false_if_block
    source = <<~LIQUID.gsub(/\n/, '')
      {% if false %}
        {% if true %}
          {% if true %}
            {% if true %}
              {{ "Hello world!" }}
            {% endif %}
          {% endif %}
        {% endif %}
      {% endif %}
    LIQUID

    template = Liquid::Template.parse(source, eager_optimize: true)
    assert_equal(0, total_node_count(template))
  end

  def test_merge_if_blocks
    # for now, work with consecutive if blocks without any String nodes in between
    source = <<~LIQUID.gsub(/\n/, '')
      {% assign foo = 1 %}
      {% if foo == 1 %}
        foo: {{ foo }}
      {% endif %}
      {% if foo == 2 %}
        foo: {{ foo }}
      {% endif %}
      {% if foo == 3 %}
        foo: {{ foo }}
      {% endif %}
    LIQUID

    original_template = Liquid::Template.parse(source, eager_optimize: false)
    template = Template.parse(source, eager_optimize: true)

    assert_equal(
      [Liquid::Assign, Liquid::If],
      template.root.nodelist.map(&:class),
    )

    [nil, 1, 2, 3, 4].each do |foo|
      assert_equal(
        original_template.render('foo' => foo),
        template.render('foo' => foo),
      )
    end
  end

  private

  def total_node_count(template)
    root = template.root
    children = root.nodelist
    count = 0

    while children.any?
      next_children = []

      children.each do |node|
        count += 1 unless node.is_a?(Liquid::BlockBody)
        next_children.concat(node.nodelist) if node.respond_to?(:nodelist) && node.nodelist
      end

      children = next_children
    end

    count
  end
end
