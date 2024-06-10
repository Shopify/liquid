# frozen_string_literal: true

require "test_helper"
require "json"

class HashTest < Minitest::Test
  include Liquid

  class HashSubclass < Hash
    def []=(key, value)
      super(fmt_key(key), value)
    end

    def [](key)
      super(fmt_key(key))
    end

    def key?(key)
      super(fmt_key(key))
    end

    def include?(key)
      super(fmt_key(key))
    end

    def to_s
      super.upcase
    end

    private

    def fmt_key(key)
      return key unless key.is_a?(String)

      key.upcase
    end
  end

  def test_size
    assert_template_result("0", "{{h.size}}", { "h" => {} })
    assert_template_result("1", "{{h.size}}", { "h" => { "a" => 1 } })
  end

  def test_first
    assert_template_result("", "{{h.first}}", { "h" => {} })
    assert_template_result("a1", "{{h.first}}", { "h" => { "a" => 1 } })
  end

  def test_last
    assert_template_result("", "{{h.last}}", { "h" => { "a" => 1 } })
  end

  def test_index
    assert_template_result("", "{{h['a']}}", { "h" => {} })
    assert_template_result("1", "{{h['a']}}", { "h" => { "a" => 1 } })
  end

  def test_to_s
    h = { "a" => 1, "b" => [1, { "c" => 2 }] }
    assert_template_result("{\"a\"=>1, \"b\"=>[1, {\"c\"=>2}]}", "{{h}}", { "h" => h })
  end

  def test_auto_methods
    h1 = { "a" => 1 }
    h2 = { "last" => 10, "first" => 11, "size" => 12 }
    assert_template_result("1,nonblank", "{{h.size}},{%if h['size'] == blank%}blank{%else%}nonblank{%endif%}", { "h" => h1 })
    assert_template_result("12,nonblank", "{{h.size}},{%if h['size'] == blank%}blank{%else%}nonblank{%endif%}", { "h" => h2 })
    assert_template_result("a1,", "{{h.first}},{{h['first']}}", { "h" => h1 })
    assert_template_result("11,11", "{{h.first}},{{h['first']}}", { "h" => h2 })
    assert_template_result(",", "{{h.last}},{{h['last']}}", { "h" => h1 })
    assert_template_result("10,10", "{{h.last}},{{h['last']}}", { "h" => h2 })
  end

  def test_equality
    h0 = {}
    h1 = { "a" => 1 }
    h2 = { "a" => 1, "b" => 2 }
    h3 = { "a" => 1 }

    hashes = [h0, h1, h2, h3]
    hashes.each_with_index do |a, i|
      hashes.each_with_index do |b, j|
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
    h = { "a" => 1, "b" => { "c" => "d" }, "3" => ["f", 2] }

    tpl = "{%if h contains b%}y{%else%}n{%endif%}"

    assert_template_result("y", tpl, { "h" => h, "b" => "a" })
    # assert_template_result("y", tpl, h, { "h" => { "b" => "a".html_safe } })
    assert_template_result("y", tpl, { "h" => h, "b" => "a".b })
    assert_template_result("n", tpl, { "h" => h, "b" => "A" })
    # assert_template_result("n", tpl, h, { "h" => { "b" => "A".html_safe } })
    assert_template_result("n", tpl, { "h" => h, "b" => "A".b })

    assert_template_result("n", tpl, { "h" => h, "b" => 1 })
    assert_template_result("n", tpl, { "h" => h, "b" => "1" })

    assert_template_result("n", tpl, { "h" => h, "b" => 3 })
    assert_template_result("y", tpl, { "h" => h, "b" => "3" })
  end

  def test_empty
    assert_template_result("y", "{%if h == empty%}y{%else%}n{%endif%}", { "h" => {} })
    assert_template_result("n", "{%if h == empty%}y{%else%}n{%endif%}", { "h" => { "a" => 1 } })
  end

  def test_blank
    assert_template_result("y", "{%if h == blank%}y{%else%}n{%endif%}", { "h" => {} })
    assert_template_result("n", "{%if h == blank%}y{%else%}n{%endif%}", { "h" => { "a" => 1 } })
  end

  def test_iter
    h0 = { "a" => 1, "b" => { "c" => "d" }, "3" => ["f", 2] }
    assert_template_result("a1b{\"c\"=>\"d\"}3f2", "{%for i in h%}{{i}}{%endfor%}", { "h" => h0 })
  end

  def test_output
    h0 = {}
    h1 = { "a" => 1, "b" => { "c" => "d" }, "3" => ["f", 2] }
    assert_template_result("{}", "{{h}}", { "h" => h0 })
    assert_template_result("{\"a\"=>1, \"b\"=>{\"c\"=>\"d\"}, \"3\"=>[\"f\", 2]}", "{{h}}", { "h" => h1 })
  end

  def test_integer_key
    h = { 2 => "huh" }
    assert_template_result("huh", "{{h[2]}}", { "h" => h })
    assert_template_result("huh", "{{h[b]}}", { "h" => h, "b" => 2 })
    assert_template_result("", "{{h[b]}}", { "h" => h, "b" => "2" })
  end

  def test_nil_key
    assert_hash_roundtrip(nil, nil)
    refute_hash_roundtrip(nil, "nil")
    refute_hash_roundtrip(nil, "null")
  end

  def test_bool_key
    assert_hash_roundtrip(true, true)
    refute_hash_roundtrip(true, false)
    refute_hash_roundtrip(true, "true")
    refute_hash_roundtrip(true, nil)
  end

  def test_int_key
    assert_hash_roundtrip(1, 1)
    refute_hash_roundtrip(1, 2)
    refute_hash_roundtrip(1, "1")
    refute_hash_roundtrip(1, 1.0000000000001)
  end

  def test_string_key
    assert_hash_roundtrip("word", "word")
    # assert_hash_roundtrip("word", "word".html_safe)
    assert_hash_roundtrip("word", "word".b)
    refute_hash_roundtrip("word", "word ")
    refute_hash_roundtrip("word", nil)
    refute_hash_roundtrip("word", true)
  end

  def test_weird_keys
    assert_hash_roundtrip([1, 2], [1, 2])
    refute_hash_roundtrip([1, 2], [1, 3])
    assert_hash_roundtrip({ "a" => 1 }, { "a" => 1 })
    refute_hash_roundtrip({ "a" => 1 }, { "a" => 2 })
    o = Struct.new(:to_liquid).new(Object.new)
    # failed_hash_roundtrip(o, o)
    refute_hash_roundtrip(o, 1)
    refute_hash_roundtrip(o, nil)
    assert_hash_roundtrip("\xff".b, "\xff".b)
    assert_hash_roundtrip(1..2, 1..2)
    refute_hash_roundtrip(1..2, 1...2)
    assert_hash_roundtrip(
      111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
      111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
    )
    # f64 hashing isn't perfect but we can make some basic assertions.
    assert_hash_roundtrip(1.1234, 1.1234)
    refute_hash_roundtrip(1.1234, 1.1)
  end

  def test_hash_html_key
    # I mean this is probably not ideal but this is the way liquid works.
    assert_template_result("{\"a<script>b\"=>\"y\"}", "{{h}}", { "h" => { "a<script>b" => "y" } })
  end

  def test_hash_subclass
    hs = HashSubclass.new
    hs["A"] = "b"
    assert_template_result("b", "{{h['a']}}", { "h" => hs })
    assert_template_result("b", "{{h['A']}}", { "h" => hs })
    assert_template_result("", "{{h['b']}}", { "h" => hs })
    assert_template_result("yes", "{% if h contains 'a' %}yes{%else%}no{%endif%}", { "h" => hs })
    assert_template_result('{"A"=>"B"}', "{{h}}", { "h" => hs })
  end

  private

  def failed_hash_roundtrip(key, test)
    assert_template_result(
      "Liquid error (templates/index line 1): internal",
      "{{h[b]}}",
      { "h" => { key => "y" }, "b" => test },
    )
  end

  def assert_hash_roundtrip(key, test)
    assert_template_result("y", "{{h[b]}}", { "h" => { key => "y" }, "b" => test })
  end

  def refute_hash_roundtrip(key, test)
    assert_template_result("", "{{h[b]}}", { "h" => { key => "y" }, "b" => test })
  end
end
