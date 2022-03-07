# frozen_string_literal: true

require 'test_helper'

class ProfilerTest < Minitest::Test
  class TestDrop < Liquid::Drop
    def initialize(value)
      super()
      @value = value
    end

    def to_s
      artificial_execution_time

      @value
    end

    private

    # Monotonic clock precision fluctuate based on the operating system
    # By introducing a small sleep we ensure ourselves to register a non zero unit of time
    def artificial_execution_time
      sleep(Process.clock_getres(Process::CLOCK_MONOTONIC))
    end
  end

  include Liquid

  class ProfilingFileSystem
    def read_template_file(template_path)
      "Rendering template {% assign template_name = '#{template_path}'%}\n{{ template_name }}"
    end
  end

  def setup
    Liquid::Template.file_system = ProfilingFileSystem.new
  end

  def test_template_allows_flagging_profiling
    t = Template.parse("{{ 'a string' | upcase }}")
    t.render!

    assert_nil(t.profiler)
  end

  def test_parse_makes_available_simple_profiling
    t = Template.parse("{{ 'a string' | upcase }}", profile: true)
    t.render!

    assert_equal(1, t.profiler.length)

    node = t.profiler[0]
    assert_equal(" 'a string' | upcase ", node.code)
  end

  def test_render_ignores_raw_strings_when_profiling
    t = Template.parse("This is raw string\nstuff\nNewline", profile: true)
    t.render!

    assert_equal(0, t.profiler.length)
  end

  def test_profiling_includes_line_numbers_of_liquid_nodes
    t = Template.parse("{{ 'a string' | upcase }}\n{% increment test %}", profile: true)
    t.render!
    assert_equal(2, t.profiler.length)

    # {{ 'a string' | upcase }}
    assert_equal(1, t.profiler[0].line_number)
    # {{ increment test }}
    assert_equal(2, t.profiler[1].line_number)
  end

  def test_profiling_includes_line_numbers_of_included_partials
    t = Template.parse("{% include 'a_template' %}", profile: true)
    t.render!

    included_children = t.profiler[0].children

    # {% assign template_name = 'a_template' %}
    assert_equal(1, included_children[0].line_number)
    # {{ template_name }}
    assert_equal(2, included_children[1].line_number)
  end

  def test_profiling_render_tag
    t = Template.parse("{% render 'a_template' %}", profile: true)
    t.render!

    render_children = t.profiler[0].children
    render_children.each do |timing|
      assert_equal('a_template', timing.partial)
    end
    assert_equal([1, 2], render_children.map(&:line_number))
  end

  def test_profiling_times_the_rendering_of_tokens
    t = Template.parse("{% include 'a_template' %}", profile: true)
    t.render!

    node = t.profiler[0]
    refute_nil(node.render_time)
  end

  def test_profiling_times_the_entire_render
    t = Template.parse("{% include 'a_template' %}", profile: true)
    t.render!

    assert(t.profiler.total_render_time >= 0, "Total render time was not calculated")
  end

  class SleepTag < Liquid::Tag
    def initialize(tag_name, markup, parse_context)
      super
      @duration = Float(markup)
    end

    def render_to_output_buffer(_context, _output)
      sleep(@duration)
    end
  end

  def test_profiling_multiple_renders
    with_custom_tag('sleep', SleepTag) do
      context = Liquid::Context.new
      t = Liquid::Template.parse("{% sleep 0.001 %}", profile: true)
      context.template_name = 'index'
      t.render!(context)
      context.template_name = 'layout'
      first_render_time = context.profiler.total_time
      t.render!(context)

      profiler = context.profiler
      children = profiler.children
      assert_operator(first_render_time, :>=, 0.001)
      assert_operator(profiler.total_time, :>=, 0.001 + first_render_time)
      assert_equal(["index", "layout"], children.map(&:template_name))
      assert_equal([nil, nil], children.map(&:code))
      assert_equal(profiler.total_time, children.map(&:total_time).reduce(&:+))
    end
  end

  def test_profiling_uses_include_to_mark_children
    t = Template.parse("{{ 'a string' | upcase }}\n{% include 'a_template' %}", profile: true)
    t.render!

    include_node = t.profiler[1]
    assert_equal(2, include_node.children.length)
  end

  def test_profiling_marks_children_with_the_name_of_included_partial
    t = Template.parse("{{ 'a string' | upcase }}\n{% include 'a_template' %}", profile: true)
    t.render!

    include_node = t.profiler[1]
    include_node.children.each do |child|
      assert_equal("a_template", child.partial)
    end
  end

  def test_profiling_supports_multiple_templates
    t = Template.parse("{{ 'a string' | upcase }}\n{% include 'a_template' %}\n{% include 'b_template' %}", profile: true)
    t.render!

    a_template = t.profiler[1]
    a_template.children.each do |child|
      assert_equal("a_template", child.partial)
    end

    b_template = t.profiler[2]
    b_template.children.each do |child|
      assert_equal("b_template", child.partial)
    end
  end

  def test_profiling_supports_rendering_the_same_partial_multiple_times
    t = Template.parse("{{ 'a string' | upcase }}\n{% include 'a_template' %}\n{% include 'a_template' %}", profile: true)
    t.render!

    a_template1 = t.profiler[1]
    a_template1.children.each do |child|
      assert_equal("a_template", child.partial)
    end

    a_template2 = t.profiler[2]
    a_template2.children.each do |child|
      assert_equal("a_template", child.partial)
    end
  end

  def test_can_iterate_over_each_profiling_entry
    t = Template.parse("{{ 'a string' | upcase }}\n{% increment test %}", profile: true)
    t.render!

    timing_count = 0
    t.profiler.each do |_timing|
      timing_count += 1
    end

    assert_equal(2, timing_count)
  end

  def test_profiling_marks_children_of_if_blocks
    t = Template.parse("{% if true %} {% increment test %} {{ test }} {% endif %}", profile: true)
    t.render!

    assert_equal(1, t.profiler.length)
    assert_equal(2, t.profiler[0].children.length)
  end

  def test_profiling_marks_children_of_for_blocks
    t = Template.parse("{% for item in collection %} {{ item }} {% endfor %}", profile: true)
    t.render!("collection" => ["one", "two"])

    assert_equal(1, t.profiler.length)
    # Will profile each invocation of the for block
    assert_equal(2, t.profiler[0].children.length)
  end

  def test_profiling_supports_self_time
    t = Template.parse("{% for item in collection %} {{ item }} {% endfor %}", profile: true)
    collection = [
      TestDrop.new("one"),
      TestDrop.new("two"),
    ]
    output = t.render!("collection" => collection)
    assert_equal(" one  two ", output)

    leaf = t.profiler[0].children[0]
    assert_operator(leaf.self_time, :>, 0.0)
  end

  def test_profiling_supports_total_time
    t = Template.parse("{% if true %} {{ test }} {% endif %}", profile: true)
    output = t.render!("test" => TestDrop.new("one"))
    assert_equal(" one ", output)

    assert_operator(t.profiler[0].total_time, :>, 0.0)
  end
end
