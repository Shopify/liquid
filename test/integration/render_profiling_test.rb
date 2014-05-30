require 'test_helper'

class RenderProfilingTest < Test::Unit::TestCase
  include Liquid

  class ProfilingFileSystem
    def read_template_file(template_path, context)
      "Rendering template {% assign template_name = '#{template_path}'%}\n{{ template_name }}"
    end
  end

  def setup
    Liquid::Template.file_system = ProfilingFileSystem.new
  end

  def test_render_makes_available_simple_profiling
    t = Template.parse("{{ 'a string' | upcase }}")
    t.render!

    assert_equal 1, t.profiling.length

    node = t.profiling[0]
    assert_equal " 'a string' | upcase ", node.code
    assert node.render_time > 0 && node.render_time < 0.01
  end

  def test_render_ignores_raw_strings_when_profiling
    t = Template.parse("This is raw string\nstuff\nNewline")
    t.render!

    assert_equal 0, t.profiling.length
  end

  def test_profiling_includes_line_numbers_of_liquid_nodes
    t = Template.parse("{{ 'a string' | upcase }}\n{% increment test %}")
    t.render!
    assert_equal 2, t.profiling.length

    # {{ 'a string' | upcase }}
    assert_equal 1, t.profiling[0].line_number
    # {{ increment test }}
    assert_equal 2, t.profiling[1].line_number
  end

  def test_profiling_uses_include_to_mark_children
    t = Template.parse("{{ 'a string' | upcase }}\n{% include 'a_template' %}")
    t.render!

    include_node = t.profiling[1]
    assert_equal 2, include_node.children.length
  end

  def test_profiling_marks_children_with_the_name_of_included_partial
    t = Template.parse("{{ 'a string' | upcase }}\n{% include 'a_template' %}")
    t.render!

    include_node = t.profiling[1]
    include_node.children.each do |child|
      assert_equal "'a_template'", child.partial
    end
  end

  def test_can_iterate_over_each_profiling_entry
    t = Template.parse("{{ 'a string' | upcase }}\n{% increment test %}")
    t.render!

    timing_count = 0
    t.profiling.each do |timing|
      timing_count += 1
    end

    assert_equal 2, timing_count
  end

  def test_profiling_marks_children_of_if_blocks
    t = Template.parse("{% if true %} {% increment test %} {{ test }} {% endif %}")
    t.render!

    assert_equal 1, t.profiling.length
    assert_equal 2, t.profiling[0].children.length
  end

  def test_profiling_marks_children_of_for_blocks
    t = Template.parse("{% for item in collection %} {{ item }} {% endfor %}")
    t.render!("collection" => ["one", "two"])

    assert_equal 1, t.profiling.length
    # Will profile each invocation of the for block
    assert_equal 2, t.profiling[0].children.length
  end
end
