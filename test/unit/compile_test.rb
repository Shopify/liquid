# frozen_string_literal: true

require 'test_helper'

# Ruby 3.3 compatibility for peek_byte and scan_byte
require 'strscan'
unless StringScanner.method_defined?(:peek_byte)
  class StringScanner
    def peek_byte
      return nil if eos?
      string.getbyte(pos)
    end
  end
end

unless StringScanner.method_defined?(:scan_byte)
  class StringScanner
    def scan_byte
      return nil if eos?
      byte = string.getbyte(pos)
      self.pos += 1
      byte
    end
  end
end

class CompileTest < Minitest::Test
  include Liquid

  def test_compile_simple_string
    template = Template.parse("Hello, World!")
    compiled = template.compile_to_ruby
    assert_equal "Hello, World!", compiled.call({})
  end

  def test_compile_variable
    template = Template.parse("Hello, {{ name }}!")
    compiled = template.compile_to_ruby
    assert_equal "Hello, World!", compiled.call({ "name" => "World" })
  end

  def test_compile_variable_with_filter
    template = Template.parse("{{ name | upcase }}")
    compiled = template.compile_to_ruby
    assert_equal "WORLD", compiled.call({ "name" => "world" })
  end

  def test_compile_variable_with_multiple_filters
    template = Template.parse("{{ name | downcase | capitalize }}")
    compiled = template.compile_to_ruby
    assert_equal "Hello", compiled.call({ "name" => "HELLO" })
  end

  def test_compile_if_true
    template = Template.parse("{% if show %}visible{% endif %}")
    compiled = template.compile_to_ruby
    assert_equal "visible", compiled.call({ "show" => true })
    assert_equal "", compiled.call({ "show" => false })
  end

  def test_compile_if_else
    template = Template.parse("{% if show %}yes{% else %}no{% endif %}")
    compiled = template.compile_to_ruby
    assert_equal "yes", compiled.call({ "show" => true })
    assert_equal "no", compiled.call({ "show" => false })
  end

  def test_compile_if_elsif
    template = Template.parse("{% if x == 1 %}one{% elsif x == 2 %}two{% else %}other{% endif %}")
    compiled = template.compile_to_ruby
    assert_equal "one", compiled.call({ "x" => 1 })
    assert_equal "two", compiled.call({ "x" => 2 })
    assert_equal "other", compiled.call({ "x" => 3 })
  end

  def test_compile_unless
    template = Template.parse("{% unless hidden %}visible{% endunless %}")
    compiled = template.compile_to_ruby
    assert_equal "visible", compiled.call({ "hidden" => false })
    assert_equal "", compiled.call({ "hidden" => true })
  end

  def test_compile_for_loop
    template = Template.parse("{% for item in items %}{{ item }} {% endfor %}")
    compiled = template.compile_to_ruby
    assert_equal "a b c ", compiled.call({ "items" => ["a", "b", "c"] })
  end

  def test_compile_for_loop_with_forloop
    template = Template.parse("{% for item in items %}{{ forloop.index }}:{{ item }} {% endfor %}")
    compiled = template.compile_to_ruby
    assert_equal "1:a 2:b 3:c ", compiled.call({ "items" => ["a", "b", "c"] })
  end

  def test_compile_for_loop_else
    template = Template.parse("{% for item in items %}{{ item }}{% else %}empty{% endfor %}")
    compiled = template.compile_to_ruby
    assert_equal "abc", compiled.call({ "items" => ["a", "b", "c"] })
    assert_equal "empty", compiled.call({ "items" => [] })
  end

  def test_compile_for_with_limit
    template = Template.parse("{% for item in items limit:2 %}{{ item }}{% endfor %}")
    compiled = template.compile_to_ruby
    assert_equal "ab", compiled.call({ "items" => ["a", "b", "c", "d"] })
  end

  def test_compile_assign
    template = Template.parse("{% assign x = 'hello' %}{{ x }}")
    compiled = template.compile_to_ruby
    assert_equal "hello", compiled.call({})
  end

  def test_compile_assign_with_filter
    template = Template.parse("{% assign x = name | upcase %}{{ x }}")
    compiled = template.compile_to_ruby
    assert_equal "WORLD", compiled.call({ "name" => "world" })
  end

  def test_compile_capture
    template = Template.parse("{% capture greeting %}Hello, {{ name }}!{% endcapture %}{{ greeting }}")
    compiled = template.compile_to_ruby
    assert_equal "Hello, World!", compiled.call({ "name" => "World" })
  end

  def test_compile_case
    template = Template.parse("{% case x %}{% when 1 %}one{% when 2 %}two{% else %}other{% endcase %}")
    compiled = template.compile_to_ruby
    assert_equal "one", compiled.call({ "x" => 1 })
    assert_equal "two", compiled.call({ "x" => 2 })
    assert_equal "other", compiled.call({ "x" => 3 })
  end

  def test_compile_raw
    template = Template.parse("{% raw %}{{ not_a_variable }}{% endraw %}")
    compiled = template.compile_to_ruby
    assert_equal "{{ not_a_variable }}", compiled.call({})
  end

  def test_compile_comment
    template = Template.parse("before{% comment %}hidden{% endcomment %}after")
    compiled = template.compile_to_ruby
    assert_equal "beforeafter", compiled.call({})
  end

  def test_compile_increment
    template = Template.parse("{% increment x %}{% increment x %}{% increment x %}")
    compiled = template.compile_to_ruby
    assert_equal "012", compiled.call({})
  end

  def test_compile_decrement
    template = Template.parse("{% decrement x %}{% decrement x %}{% decrement x %}")
    compiled = template.compile_to_ruby
    assert_equal "-1-2-3", compiled.call({})
  end

  def test_compile_cycle
    template = Template.parse("{% for i in (1..3) %}{% cycle 'a', 'b' %}{% endfor %}")
    compiled = template.compile_to_ruby
    assert_equal "aba", compiled.call({})
  end

  def test_compile_nested_property_access
    template = Template.parse("{{ user.profile.name }}")
    compiled = template.compile_to_ruby
    data = { "user" => { "profile" => { "name" => "Alice" } } }
    assert_equal "Alice", compiled.call(data)
  end

  def test_compile_array_access
    template = Template.parse("{{ items[1] }}")
    compiled = template.compile_to_ruby
    assert_equal "b", compiled.call({ "items" => ["a", "b", "c"] })
  end

  def test_compile_size_filter
    template = Template.parse("{{ items | size }}")
    compiled = template.compile_to_ruby
    assert_equal "3", compiled.call({ "items" => [1, 2, 3] })
  end

  def test_compile_join_filter
    template = Template.parse("{{ items | join: ', ' }}")
    compiled = template.compile_to_ruby
    assert_equal "a, b, c", compiled.call({ "items" => ["a", "b", "c"] })
  end

  def test_compile_split_filter
    template = Template.parse("{% assign arr = str | split: ',' %}{{ arr | size }}")
    compiled = template.compile_to_ruby
    assert_equal "3", compiled.call({ "str" => "a,b,c" })
  end

  def test_compile_math_filters
    template = Template.parse("{{ x | plus: 5 | minus: 2 | times: 3 }}")
    compiled = template.compile_to_ruby
    assert_equal "24", compiled.call({ "x" => 5 })
  end

  def test_compile_default_filter
    template = Template.parse("{{ x | default: 'nothing' }}")
    compiled = template.compile_to_ruby
    assert_equal "hello", compiled.call({ "x" => "hello" })
    assert_equal "nothing", compiled.call({ "x" => nil })
    assert_equal "nothing", compiled.call({})
  end

  def test_compile_first_last_filters
    template = Template.parse("{{ items | first }}-{{ items | last }}")
    compiled = template.compile_to_ruby
    assert_equal "a-c", compiled.call({ "items" => ["a", "b", "c"] })
  end

  def test_compile_escape_filter
    template = Template.parse("{{ html | escape }}")
    compiled = template.compile_to_ruby
    assert_equal "&lt;p&gt;hello&lt;/p&gt;", compiled.call({ "html" => "<p>hello</p>" })
  end

  def test_compile_replace_filter
    template = Template.parse("{{ str | replace: 'foo', 'bar' }}")
    compiled = template.compile_to_ruby
    assert_equal "bar baz bar", compiled.call({ "str" => "foo baz foo" })
  end

  def test_compile_append_prepend_filters
    template = Template.parse("{{ name | prepend: 'Hello, ' | append: '!' }}")
    compiled = template.compile_to_ruby
    assert_equal "Hello, World!", compiled.call({ "name" => "World" })
  end

  def test_compile_for_break
    template = Template.parse("{% for i in (1..5) %}{% if i == 3 %}{% break %}{% endif %}{{ i }}{% endfor %}")
    compiled = template.compile_to_ruby
    assert_equal "12", compiled.call({})
  end

  def test_compile_for_continue
    template = Template.parse("{% for i in (1..5) %}{% if i == 3 %}{% continue %}{% endif %}{{ i }}{% endfor %}")
    compiled = template.compile_to_ruby
    assert_equal "1245", compiled.call({})
  end

  def test_compile_comparison_operators
    template = Template.parse("{% if x > 5 %}big{% elsif x == 5 %}five{% else %}small{% endif %}")
    compiled = template.compile_to_ruby
    assert_equal "big", compiled.call({ "x" => 10 })
    assert_equal "five", compiled.call({ "x" => 5 })
    assert_equal "small", compiled.call({ "x" => 2 })
  end

  def test_compile_and_or_operators
    template = Template.parse("{% if a and b %}both{% elsif a or b %}one{% else %}none{% endif %}")
    compiled = template.compile_to_ruby
    assert_equal "both", compiled.call({ "a" => true, "b" => true })
    assert_equal "one", compiled.call({ "a" => true, "b" => false })
    assert_equal "none", compiled.call({ "a" => false, "b" => false })
  end

  def test_compile_contains
    template = Template.parse("{% if str contains 'hello' %}found{% else %}not found{% endif %}")
    compiled = template.compile_to_ruby
    assert_equal "found", compiled.call({ "str" => "say hello world" })
    assert_equal "not found", compiled.call({ "str" => "goodbye" })
  end

  def test_compile_produces_valid_ruby
    template = Template.parse("{% for item in items %}{{ item | upcase }}{% endfor %}")
    compiled = template.compile_to_ruby

    # Should produce valid Ruby syntax - if eval succeeds without error, it's valid
    proc = eval(compiled.code)
    assert_kind_of Proc, proc
  end

  def test_compile_vs_render_equivalence
    templates = [
      "Hello, {{ name }}!",
      "{% if show %}visible{% else %}hidden{% endif %}",
      "{% for i in (1..3) %}{{ i }}{% endfor %}",
      "{{ str | upcase | split: '' | join: '-' }}",
      "{% assign x = 5 %}{% assign y = x | plus: 3 %}{{ y }}",
    ]

    assigns_list = [
      { "name" => "World", "show" => true, "str" => "hello" },
      { "name" => "Ruby", "show" => false, "str" => "test" },
    ]

    templates.each do |source|
      template = Template.parse(source)
      compiled = template.compile_to_ruby

      assigns_list.each do |assigns|
        expected = template.render(assigns)
        actual = compiled.call(assigns.dup)
        assert_equal expected, actual, "Mismatch for template '#{source}' with assigns #{assigns}"
      end
    end
  end

  def test_compiled_template_class
    template = Template.parse("Hello, {{ name }}!")
    compiled = template.compile_to_ruby

    assert_instance_of Liquid::Compile::CompiledTemplate, compiled
    assert_respond_to compiled, :call
    assert_respond_to compiled, :code
    assert_respond_to compiled, :to_s
    assert_respond_to compiled, :to_proc
  end

  def test_compiled_template_code
    template = Template.parse("Hello!")
    compiled = template.compile_to_ruby

    assert_kind_of String, compiled.code
    assert_includes compiled.code, "__output__"
    assert_includes compiled.code, "Hello!"
  end

  def test_external_tags_indicator
    # A simple template should have no external tags
    template = Template.parse("Hello!")
    compiled = template.compile_to_ruby

    assert_equal false, compiled.has_external_tags?
    assert_empty compiled.external_tags
  end

  def test_external_filters_indicator
    # A simple template should have no external filters
    template = Template.parse("{{ name | upcase }}")
    compiled = template.compile_to_ruby

    assert_equal false, compiled.has_external_filters?
  end

  def test_comprehensive_output_equivalence
    # Comprehensive test comparing compiled vs interpreted output
    test_cases = [
      # Basic variables
      { source: "{{ x }}", assigns: { "x" => "hello" } },
      { source: "{{ x }}", assigns: { "x" => 123 } },
      { source: "{{ x }}", assigns: { "x" => nil } },

      # Nested access
      { source: "{{ a.b.c }}", assigns: { "a" => { "b" => { "c" => "deep" } } } },
      { source: "{{ items[0] }}", assigns: { "items" => ["first", "second"] } },

      # Filters
      { source: "{{ x | upcase }}", assigns: { "x" => "hello" } },
      { source: "{{ x | size }}", assigns: { "x" => [1, 2, 3] } },
      { source: "{{ x | default: 'fallback' }}", assigns: { "x" => nil } },
      { source: "{{ x | plus: 10 }}", assigns: { "x" => 5 } },
      { source: "{{ x | split: ',' | first }}", assigns: { "x" => "a,b,c" } },

      # Conditionals
      { source: "{% if x %}yes{% endif %}", assigns: { "x" => true } },
      { source: "{% if x %}yes{% endif %}", assigns: { "x" => false } },
      { source: "{% if x > 5 %}big{% else %}small{% endif %}", assigns: { "x" => 10 } },

      # Loops
      { source: "{% for i in items %}{{ i }}{% endfor %}", assigns: { "items" => [1, 2, 3] } },
      { source: "{% for i in (1..3) %}{{ i }}{% endfor %}", assigns: {} },
      { source: "{% for i in items %}{{ forloop.index }}{% endfor %}", assigns: { "items" => %w[a b] } },
      { source: "{% for i in items %}{% if forloop.first %}first{% endif %}{% endfor %}", assigns: { "items" => [1, 2] } },

      # Assignments
      { source: "{% assign y = x | upcase %}{{ y }}", assigns: { "x" => "hello" } },
      { source: "{% capture c %}Hello {{ x }}{% endcapture %}{{ c }}", assigns: { "x" => "World" } },

      # Case
      { source: "{% case x %}{% when 1 %}one{% when 2 %}two{% else %}other{% endcase %}", assigns: { "x" => 1 } },
      { source: "{% case x %}{% when 1 %}one{% when 2 %}two{% else %}other{% endcase %}", assigns: { "x" => 3 } },

      # Increment/Decrement
      { source: "{% increment x %}{% increment x %}", assigns: {} },
      { source: "{% decrement x %}{% decrement x %}", assigns: {} },

      # Cycle
      { source: "{% for i in (1..4) %}{% cycle 'a', 'b' %}{% endfor %}", assigns: {} },

      # Break/Continue
      { source: "{% for i in (1..5) %}{% if i == 3 %}{% break %}{% endif %}{{ i }}{% endfor %}", assigns: {} },
      { source: "{% for i in (1..5) %}{% if i == 3 %}{% continue %}{% endif %}{{ i }}{% endfor %}", assigns: {} },

      # Raw
      { source: "{% raw %}{{ not a var }}{% endraw %}", assigns: {} },

      # Comment
      { source: "before{% comment %}hidden{% endcomment %}after", assigns: {} },

      # Tablerow
      { source: "{% tablerow i in items cols:2 %}{{ i }}{% endtablerow %}", assigns: { "items" => [1, 2, 3] } },
    ]

    test_cases.each do |tc|
      source = tc[:source]
      assigns = tc[:assigns]

      template = Template.parse(source)
      compiled = template.compile_to_ruby

      expected = template.render(assigns.dup)
      actual = compiled.call(assigns.dup)

      assert_equal expected, actual, "Output mismatch for: #{source.inspect}\nAssigns: #{assigns.inspect}"
    end
  end

  def test_debug_mode_adds_comments
    template = Template.parse("{{ name }}")
    compiled = template.compile_to_ruby(debug: true)

    assert_includes compiled.code, "# LIQUID"
    assert_includes compiled.code, "# Compiled from Liquid template"
  end

  def test_filter_handler_can_be_set
    # Create a custom filter module
    filter_mod = Module.new do
      def custom_filter(input)
        "custom:#{input}"
      end
    end

    class_with_filter = Class.new do
      include filter_mod
    end

    template = Template.parse("{{ x | custom_filter }}")
    compiled = template.compile_to_ruby
    compiled.filter_handler = class_with_filter.new

    # The template should use the custom filter
    result = compiled.call({ "x" => "test" })
    assert_equal "custom:test", result
  end
end
