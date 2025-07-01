# frozen_string_literal: true

require 'test_helper'

class HashRenderingTest < Minitest::Test
  def test_render_empty_hash
    assert_template_result("{}", "{{ my_hash }}", { "my_hash" => {} })
  end

  def test_render_hash_with_string_keys_and_values
    assert_template_result("{\"key1\"=>\"value1\", \"key2\"=>\"value2\"}", "{{ my_hash }}", { "my_hash" => { "key1" => "value1", "key2" => "value2" } })
  end

  def test_render_hash_with_symbol_keys_and_integer_values
    assert_template_result("{:key1=>1, :key2=>2}", "{{ my_hash }}", { "my_hash" => { key1: 1, key2: 2 } })
  end

  def test_render_nested_hash
    assert_template_result("{\"outer\"=>{\"inner\"=>\"value\"}}", "{{ my_hash }}", { "my_hash" => { "outer" => { "inner" => "value" } } })
  end

  def test_render_hash_with_array_values
    assert_template_result("{\"numbers\"=>[1, 2, 3]}", "{{ my_hash }}", { "my_hash" => { "numbers" => [1, 2, 3] } })
  end

  def test_render_recursive_hash
    recursive_hash = { "self" => {} }
    recursive_hash["self"]["self"] = recursive_hash
    assert_template_result("{\"self\"=>{\"self\"=>{...}}}", "{{ my_hash }}", { "my_hash" => recursive_hash })
  end

  def test_hash_with_downcase_filter
    assert_template_result("{\"key\"=>\"value\", \"anotherkey\"=>\"anothervalue\"}", "{{ my_hash | downcase }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_hash_with_upcase_filter
    assert_template_result("{\"KEY\"=>\"VALUE\", \"ANOTHERKEY\"=>\"ANOTHERVALUE\"}", "{{ my_hash | upcase }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_hash_with_strip_filter
    assert_template_result("{\"Key\"=>\"Value\", \"AnotherKey\"=>\"AnotherValue\"}", "{{ my_hash | strip }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_hash_with_escape_filter
    assert_template_result("{&quot;Key&quot;=&gt;&quot;Value&quot;, &quot;AnotherKey&quot;=&gt;&quot;AnotherValue&quot;}", "{{ my_hash | escape }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_hash_with_url_encode_filter
    assert_template_result("%7B%22Key%22%3D%3E%22Value%22%2C+%22AnotherKey%22%3D%3E%22AnotherValue%22%7D", "{{ my_hash | url_encode }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_hash_with_strip_html_filter
    assert_template_result("{\"Key\"=>\"Value\", \"AnotherKey\"=>\"AnotherValue\"}", "{{ my_hash | strip_html }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_hash_with_truncate__20_filter
    assert_template_result("{\"Key\"=>\"Value\", ...", "{{ my_hash | truncate: 20 }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_hash_with_replace___key____replaced_key__filter
    assert_template_result("{\"Key\"=>\"Value\", \"AnotherKey\"=>\"AnotherValue\"}", "{{ my_hash | replace: 'key', 'replaced_key' }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_hash_with_append____appended_text__filter
    assert_template_result("{\"Key\"=>\"Value\", \"AnotherKey\"=>\"AnotherValue\"} appended text", "{{ my_hash | append: ' appended text' }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_hash_with_prepend___prepended_text___filter
    assert_template_result("prepended text {\"Key\"=>\"Value\", \"AnotherKey\"=>\"AnotherValue\"}", "{{ my_hash | prepend: 'prepended text ' }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_render_hash_with_array_values_empty
    assert_template_result("{\"numbers\"=>[]}", "{{ my_hash }}", { "my_hash" => { "numbers" => [] } })
  end

  def test_render_hash_with_array_values_hash
    assert_template_result("{\"numbers\"=>[{:foo=>42}]}", "{{ my_hash }}", { "my_hash" => { "numbers" => [{ foo: 42 }] } })
  end

  def test_join_filter_with_hash
    array = [{ "key1" => "value1" }, { "key2" => "value2" }]
    glue = { "lol" => "wut" }
    assert_template_result("{\"key1\"=>\"value1\"}{\"lol\"=>\"wut\"}{\"key2\"=>\"value2\"}", "{{ my_array | join: glue }}", { "my_array" => array, "glue" => glue })
  end

  def test_render_hash_with_hash_key
    assert_template_result("{{\"foo\"=>\"bar\"}=>42}", "{{ my_hash }}", { "my_hash" => { Hash["foo" => "bar"] => 42 } })
  end

  def test_rendering_hash_with_custom_to_s_method_uses_custom_to_s
    my_hash = Class.new(Hash) do
      def to_s
        "kewl"
      end
    end.new

    assert_template_result("kewl", "{{ my_hash }}", { "my_hash" => my_hash })
  end

  def test_rendering_hash_without_custom_to_s_uses_default_inspect
    my_hash = Class.new(Hash).new
    my_hash[:foo] = :bar

    assert_template_result("{:foo=>:bar}", "{{ my_hash }}", { "my_hash" => my_hash })
  end
end
