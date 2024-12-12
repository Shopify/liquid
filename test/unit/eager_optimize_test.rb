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

    assert_optimization([Liquid::If], source, { "foo" => nil })
    assert_optimization([Liquid::If], source, { "foo" => 1 })
    assert_optimization([Liquid::If], source, { "foo" => 2 })
    assert_optimization([Liquid::If], source, { "foo" => 5 })

    source = <<~LIQUID.gsub(/\n/, '')
      {% assign bar = "application" %}
      {% if foo == 1 %}
        foo: {{ foo }}
      {% endif %}
      {% if foo == 2 and bar contains "app" %}
        foo: {{ foo }}
      {% endif %}
      {% if 3 == foo and bar == "application" %}
        foo: {{ foo }}
      {% endif %}
    LIQUID

    assert_optimization([Liquid::Assign, Liquid::If], source)
  end

  def test_does_not_merge_if_blocks
    assert_optimization([Liquid::If, Liquid::If], <<~LIQUID.gsub(/\n/, ''))
      {% if foo == 1 %}
        foo: {{ foo }}
      {% endif %}
      {% if k == 1 %}
        foo: {{ foo }}
      {% endif %}
    LIQUID

    assert_optimization([Liquid::If, Liquid::If], <<~LIQUID.gsub(/\n/, ''))
      {% if foo == 1 %}
        foo: {{ foo }}
      {% endif %}
      {% if foo == 1 %}
        foo: {{ foo }}
      {% endif %}
    LIQUID

    assert_optimization([Liquid::If, Liquid::If], <<~LIQUID.gsub(/\n/, ''))
      {% if foo == 1 %}
        foo: {{ foo }}
      {% endif %}
      {% if a == foo %}
        foo: {{ foo }}
      {% endif %}
    LIQUID

    assert_optimization([Liquid::If, Liquid::If], <<~LIQUID.gsub(/\n/, ''))
      {% if foo %}
        foo: {{ foo }}
      {% endif %}
      {% if foo %}
        foo: {{ foo }}
      {% endif %}
    LIQUID

    assert_optimization([Liquid::If, Liquid::If], <<~LIQUID.gsub(/\n/, ''))
      {% if foo == 1 %}
        foo: {{ foo }}
      {% endif %}
      {% if foo >= 1 %}
        foo: {{ foo }}
      {% endif %}
    LIQUID

    assert_optimization([Liquid::If, Liquid::If], <<~LIQUID.gsub(/\n/, ''))
      {% if foo == 1 %}
        foo: {{ foo }}
      {% endif %}
      {% if 1  %}
        foo: {{ foo }}
      {% endif %}
    LIQUID
  end

  private

  def assert_optimization(expected, source, context = { "foo" => 1 })
    template = Template.parse(source, eager_optimize: true)
    assert_equal(expected, template.root.nodelist.map(&:class),)

    baseline_template = Template.parse(source, eager_optimize: false)

    assert_equal(
      baseline_template.render(context),
      template.render(context),
    )
  end

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
