# frozen_string_literal: true

require 'test_helper'

class ArrayTest < Minitest::Test
  include Liquid

  def test_array_size
    assert_template_result("0", "{{a.size}}", { 'a' => [] })
    assert_template_result("2", "{{a.size}}", { 'a' => [1, 2] })
  end

  def test_array_first
    assert_template_result("", "{{a.first}}", { 'a' => [] })
    assert_template_result("1", "{{a.first}}", { 'a' => [1, 2] })
  end

  def test_array_last
    assert_template_result("", "{{a.last}}", { 'a' => [] })
    assert_template_result("2", "{{a.last}}", { 'a' => [1, 2] })
  end

  def test_array_index
    assert_template_result("", "{{a[1]}}", { 'a' => [] })
    assert_template_result("2", "{{a[1]}}", { 'a' => [1, 2] })
  end

  def test_negative_array_index
    assert_template_result("3", "{{a[-1]}}", { 'a' => [1, 2, 3] })
    assert_template_result("1", "{{a[-3]}}", { 'a' => [1, 2, 3] })
    assert_template_result("", "{{a[-4]}}", { 'a' => [1, 2, 3] })
  end

  def test_array_to_s
    arr = ["a", ["b", 1], "c"]
    assert_template_result("ab1c", "{{a}}", { 'a' => arr })
  end

  def test_auto_methods
    a1 = []
    a2 = [1, 2, 3, "abc"]
    assert_template_result("0,nonblank", "{{a.size}},{%if a['size'] == blank%}blank{%else%}nonblank{%endif%}", { 'a' => a1 })
    assert_template_result("4,nonblank", "{{a.size}},{%if a['size'] == blank%}blank{%else%}nonblank{%endif%}", { 'a' => a2 })
    assert_template_result(",", "{{a.first}},{{a['first']}}", { 'a' => a1 })
    assert_template_result("1,", "{{a.first}},{{a['first']}}", { 'a' => a2 })
    assert_template_result(",", "{{a.last}},{{a['last']}}", { 'a' => a1 })
    assert_template_result("abc,", "{{a.last}},{{a['last']}}", { 'a' => a2 })
  end

  def test_array_equality
    a0 = []
    a1 = [1]
    a2 = [1, 2]
    a3 = [1]

    arrays = [a0, a1, a2, a3]
    arrays.each_with_index do |a, i|
      arrays.each_with_index do |b, j|
        prefix = "(#{i},#{j})"
        assert_template_result(
          prefix + (a == b ? "y" : "n"),
          "#{prefix}{% if a == b %}y{%else%}n{%endif%}",
          { "a" => a, "b" => b },
        )
      end
    end
  end

  def test_contains
    a0 = [1, "a", ["b", "c"], true]
    a1 = ["b", "c"]
    a2 = ["B", "C"]

    tpl = "{%if a contains b%}y{%else%}n{%endif%}"

    assert_template_result("y", tpl, { "a" => a0, "b" => 1 })
    assert_template_result("n", tpl, { "a" => a0, "b" => 2 })
    assert_template_result("y", tpl, { "a" => a0, "b" => a1 })
    assert_template_result("n", tpl, { "a" => a0, "b" => a2 })
  end

  def test_empty
    assert_template_result("y", "{%if a == empty%}y{%else%}n{%endif%}", { 'a' => [] })
    assert_template_result("n", "{%if a == empty%}y{%else%}n{%endif%}", { 'a' => [1, 2] })
  end

  def test_blank
    assert_template_result("y", "{%if a == blank%}y{%else%}n{%endif%}", { 'a' => [] })
    assert_template_result("n", "{%if a == blank%}y{%else%}n{%endif%}", { 'a' => [1, 2] })
  end

  def test_iter
    a0 = [1, "a"]
    assert_template_result("1a", "{%for i in a%}{{i}}{%endfor%}", { 'a' => a0 })
  end

  def test_output
    a0 = []
    a1 = [1, "a", ["b", "c"], true]
    assert_template_result("", "{{a}}", { 'a' => a0 })
    assert_template_result("1abctrue", "{{a}}", { 'a' => a1 })
  end
end
