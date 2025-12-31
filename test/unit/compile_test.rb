# frozen_string_literal: true

require 'test_helper'

class CompileTest < Minitest::Test
  include Liquid

  def test_compile_simple_string
    template = Template.parse("Hello, World!")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "Hello, World!", render_proc.call({})
  end

  def test_compile_variable
    template = Template.parse("Hello, {{ name }}!")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "Hello, World!", render_proc.call({ "name" => "World" })
  end

  def test_compile_variable_with_filter
    template = Template.parse("{{ name | upcase }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "WORLD", render_proc.call({ "name" => "world" })
  end

  def test_compile_variable_with_multiple_filters
    template = Template.parse("{{ name | downcase | capitalize }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "Hello", render_proc.call({ "name" => "HELLO" })
  end

  def test_compile_if_true
    template = Template.parse("{% if show %}visible{% endif %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "visible", render_proc.call({ "show" => true })
    assert_equal "", render_proc.call({ "show" => false })
  end

  def test_compile_if_else
    template = Template.parse("{% if show %}yes{% else %}no{% endif %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "yes", render_proc.call({ "show" => true })
    assert_equal "no", render_proc.call({ "show" => false })
  end

  def test_compile_if_elsif
    template = Template.parse("{% if x == 1 %}one{% elsif x == 2 %}two{% else %}other{% endif %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "one", render_proc.call({ "x" => 1 })
    assert_equal "two", render_proc.call({ "x" => 2 })
    assert_equal "other", render_proc.call({ "x" => 3 })
  end

  def test_compile_unless
    template = Template.parse("{% unless hidden %}visible{% endunless %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "visible", render_proc.call({ "hidden" => false })
    assert_equal "", render_proc.call({ "hidden" => true })
  end

  def test_compile_for_loop
    template = Template.parse("{% for item in items %}{{ item }} {% endfor %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "a b c ", render_proc.call({ "items" => ["a", "b", "c"] })
  end

  def test_compile_for_loop_with_forloop
    template = Template.parse("{% for item in items %}{{ forloop.index }}:{{ item }} {% endfor %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "1:a 2:b 3:c ", render_proc.call({ "items" => ["a", "b", "c"] })
  end

  def test_compile_for_loop_else
    template = Template.parse("{% for item in items %}{{ item }}{% else %}empty{% endfor %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "abc", render_proc.call({ "items" => ["a", "b", "c"] })
    assert_equal "empty", render_proc.call({ "items" => [] })
  end

  def test_compile_for_with_limit
    template = Template.parse("{% for item in items limit:2 %}{{ item }}{% endfor %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "ab", render_proc.call({ "items" => ["a", "b", "c", "d"] })
  end

  def test_compile_assign
    template = Template.parse("{% assign x = 'hello' %}{{ x }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "hello", render_proc.call({})
  end

  def test_compile_assign_with_filter
    template = Template.parse("{% assign x = name | upcase %}{{ x }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "WORLD", render_proc.call({ "name" => "world" })
  end

  def test_compile_capture
    template = Template.parse("{% capture greeting %}Hello, {{ name }}!{% endcapture %}{{ greeting }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "Hello, World!", render_proc.call({ "name" => "World" })
  end

  def test_compile_case
    template = Template.parse("{% case x %}{% when 1 %}one{% when 2 %}two{% else %}other{% endcase %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "one", render_proc.call({ "x" => 1 })
    assert_equal "two", render_proc.call({ "x" => 2 })
    assert_equal "other", render_proc.call({ "x" => 3 })
  end

  def test_compile_raw
    template = Template.parse("{% raw %}{{ not_a_variable }}{% endraw %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "{{ not_a_variable }}", render_proc.call({})
  end

  def test_compile_comment
    template = Template.parse("before{% comment %}hidden{% endcomment %}after")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "beforeafter", render_proc.call({})
  end

  def test_compile_increment
    template = Template.parse("{% increment x %}{% increment x %}{% increment x %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "012", render_proc.call({})
  end

  def test_compile_decrement
    template = Template.parse("{% decrement x %}{% decrement x %}{% decrement x %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "-1-2-3", render_proc.call({})
  end

  def test_compile_cycle
    template = Template.parse("{% for i in (1..3) %}{% cycle 'a', 'b' %}{% endfor %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "aba", render_proc.call({})
  end

  def test_compile_nested_property_access
    template = Template.parse("{{ user.profile.name }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    data = { "user" => { "profile" => { "name" => "Alice" } } }
    assert_equal "Alice", render_proc.call(data)
  end

  def test_compile_array_access
    template = Template.parse("{{ items[1] }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "b", render_proc.call({ "items" => ["a", "b", "c"] })
  end

  def test_compile_size_filter
    template = Template.parse("{{ items | size }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "3", render_proc.call({ "items" => [1, 2, 3] })
  end

  def test_compile_join_filter
    template = Template.parse("{{ items | join: ', ' }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "a, b, c", render_proc.call({ "items" => ["a", "b", "c"] })
  end

  def test_compile_split_filter
    template = Template.parse("{% assign arr = str | split: ',' %}{{ arr | size }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "3", render_proc.call({ "str" => "a,b,c" })
  end

  def test_compile_math_filters
    template = Template.parse("{{ x | plus: 5 | minus: 2 | times: 3 }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "24", render_proc.call({ "x" => 5 })
  end

  def test_compile_default_filter
    template = Template.parse("{{ x | default: 'nothing' }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "hello", render_proc.call({ "x" => "hello" })
    assert_equal "nothing", render_proc.call({ "x" => nil })
    assert_equal "nothing", render_proc.call({})
  end

  def test_compile_first_last_filters
    template = Template.parse("{{ items | first }}-{{ items | last }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "a-c", render_proc.call({ "items" => ["a", "b", "c"] })
  end

  def test_compile_escape_filter
    template = Template.parse("{{ html | escape }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "&lt;p&gt;hello&lt;/p&gt;", render_proc.call({ "html" => "<p>hello</p>" })
  end

  def test_compile_replace_filter
    template = Template.parse("{{ str | replace: 'foo', 'bar' }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "bar baz bar", render_proc.call({ "str" => "foo baz foo" })
  end

  def test_compile_append_prepend_filters
    template = Template.parse("{{ name | prepend: 'Hello, ' | append: '!' }}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "Hello, World!", render_proc.call({ "name" => "World" })
  end

  def test_compile_for_break
    template = Template.parse("{% for i in (1..5) %}{% if i == 3 %}{% break %}{% endif %}{{ i }}{% endfor %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "12", render_proc.call({})
  end

  def test_compile_for_continue
    template = Template.parse("{% for i in (1..5) %}{% if i == 3 %}{% continue %}{% endif %}{{ i }}{% endfor %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "1245", render_proc.call({})
  end

  def test_compile_comparison_operators
    template = Template.parse("{% if x > 5 %}big{% elsif x == 5 %}five{% else %}small{% endif %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "big", render_proc.call({ "x" => 10 })
    assert_equal "five", render_proc.call({ "x" => 5 })
    assert_equal "small", render_proc.call({ "x" => 2 })
  end

  def test_compile_and_or_operators
    template = Template.parse("{% if a and b %}both{% elsif a or b %}one{% else %}none{% endif %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "both", render_proc.call({ "a" => true, "b" => true })
    assert_equal "one", render_proc.call({ "a" => true, "b" => false })
    assert_equal "none", render_proc.call({ "a" => false, "b" => false })
  end

  def test_compile_contains
    template = Template.parse("{% if str contains 'hello' %}found{% else %}not found{% endif %}")
    ruby_code = template.compile_to_ruby
    render_proc = eval(ruby_code)
    assert_equal "found", render_proc.call({ "str" => "say hello world" })
    assert_equal "not found", render_proc.call({ "str" => "goodbye" })
  end

  def test_compile_produces_valid_ruby
    template = Template.parse("{% for item in items %}{{ item | upcase }}{% endfor %}")
    ruby_code = template.compile_to_ruby

    # Should produce valid Ruby syntax
    assert_nothing_raised do
      eval(ruby_code)
    end
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
      ruby_code = template.compile_to_ruby
      render_proc = eval(ruby_code)

      assigns_list.each do |assigns|
        expected = template.render(assigns)
        actual = render_proc.call(assigns.dup)
        assert_equal expected, actual, "Mismatch for template '#{source}' with assigns #{assigns}"
      end
    end
  end
end
