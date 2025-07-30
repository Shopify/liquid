# frozen_string_literal: true

require 'test_helper'

class JsonSchemaUnitTest < Minitest::Test
  def test_build_recording_data
    data = Liquid::TemplateRecorder::JsonSchema.build_recording_data(
      template_source: "{{ name }}",
      assigns: { "name" => "test" },
      file_reads: { "header" => "content" },
      filter_calls: [{ name: "upcase", input: "test", output: "TEST" }],
      output: "TEST",
      entrypoint: "test.liquid"
    )

    assert_equal 1, data['schema_version']
    assert_equal Liquid::VERSION, data['engine']['liquid_version']
    assert_equal "{{ name }}", data['template']['source']
    assert_equal "test.liquid", data['template']['entrypoint']
    assert data['template']['sha256']
    assert_equal({ "name" => "test" }, data['data']['variables'])
    assert_equal({ "header" => "content" }, data['file_system'])
    assert_equal [{ name: "upcase", input: "test", output: "TEST" }], data['filters']
    assert_equal({ "string" => "TEST" }, data['output'])
    assert data['metadata']['timestamp']
    assert_equal 1, data['metadata']['recorder_version']
  end

  def test_serialize_and_deserialize
    data = {
      'schema_version' => 1,
      'engine' => {
        'liquid_version' => '1.0.0',
        'ruby_version' => '3.0.0',
        'settings' => {}
      },
      'template' => {
        'source' => '{{ test }}',
        'sha256' => 'abc123'
      },
      'data' => {
        'variables' => { 'test' => 'value' }
      }
    }

    json_string = Liquid::TemplateRecorder::JsonSchema.serialize(data)
    assert json_string.is_a?(String)
    assert json_string.include?('"schema_version": 1')

    deserialized = Liquid::TemplateRecorder::JsonSchema.deserialize(json_string)
    assert_equal 1, deserialized['schema_version']
    assert_equal '{{ test }}', deserialized['template']['source']
    assert_equal({ 'test' => 'value' }, deserialized['data']['variables'])
  end

  def test_validate_schema_success
    valid_data = {
      'schema_version' => 1,
      'engine' => {
        'liquid_version' => '1.0.0',
        'ruby_version' => '3.0.0',
        'settings' => {}
      },
      'template' => {
        'source' => '{{ test }}',
        'sha256' => 'abc123'
      },
      'data' => {
        'variables' => { 'test' => 'value' }
      }
    }

    # Should not raise an exception
    Liquid::TemplateRecorder::JsonSchema.validate_schema(valid_data)
  end

  def test_validate_schema_missing_fields
    invalid_data = {
      'schema_version' => 1
      # Missing required fields
    }

    assert_raises(Liquid::TemplateRecorder::SchemaError) do
      Liquid::TemplateRecorder::JsonSchema.validate_schema(invalid_data)
    end
  end

  def test_validate_schema_wrong_version
    invalid_data = {
      'schema_version' => 999,
      'engine' => {},
      'template' => {},
      'data' => {}
    }

    error = assert_raises(Liquid::TemplateRecorder::SchemaError) do
      Liquid::TemplateRecorder::JsonSchema.validate_schema(invalid_data)
    end
    
    assert error.message.include?("Unsupported schema version")
  end

  def test_validate_schema_invalid_template
    invalid_data = {
      'schema_version' => 1,
      'engine' => {
        'liquid_version' => '1.0.0',
        'ruby_version' => '3.0.0',
        'settings' => {}
      },
      'template' => {
        # Missing required source field
        'sha256' => 'abc123'
      },
      'data' => {
        'variables' => {}
      }
    }

    assert_raises(Liquid::TemplateRecorder::SchemaError) do
      Liquid::TemplateRecorder::JsonSchema.validate_schema(invalid_data)
    end
  end

  def test_validate_schema_non_serializable_variables
    invalid_data = {
      'schema_version' => 1,
      'engine' => {
        'liquid_version' => '1.0.0',
        'ruby_version' => '3.0.0',
        'settings' => {}
      },
      'template' => {
        'source' => '{{ test }}',
        'sha256' => 'abc123'
      },
      'data' => {
        'variables' => {
          'valid' => 'string',
          'invalid' => Object.new  # Non-serializable
        }
      }
    }

    assert_raises(Liquid::TemplateRecorder::SchemaError) do
      Liquid::TemplateRecorder::JsonSchema.validate_schema(invalid_data)
    end
  end

  def test_ensure_serializable
    input = {
      'string' => 'test',
      'number' => 42,
      'boolean' => true,
      'null' => nil,
      'array' => [1, 'two', true],
      'nested_hash' => {
        'key' => 'value',
        'number' => 123
      },
      'object' => Object.new,
      'symbol' => :symbol
    }

    result = Liquid::TemplateRecorder::JsonSchema.send(:ensure_serializable, input)

    assert_equal 'test', result['string']
    assert_equal 42, result['number']
    assert_equal true, result['boolean']
    assert_nil result['null']
    assert_equal [1, 'two', true], result['array']
    assert_equal({ 'key' => 'value', 'number' => 123 }, result['nested_hash'])
    
    # Non-serializable objects should be converted to strings
    assert result['object'].is_a?(String)
    assert result['symbol'].is_a?(String)
  end

  def test_ensure_serializable_with_nested_arrays
    input = {
      'matrix' => [
        [1, 2, 3],
        ['a', 'b', 'c'],
        [{ 'nested' => 'hash' }]
      ]
    }

    result = Liquid::TemplateRecorder::JsonSchema.send(:ensure_serializable, input)
    
    assert_equal [1, 2, 3], result['matrix'][0]
    assert_equal ['a', 'b', 'c'], result['matrix'][1]
    assert_equal [{ 'nested' => 'hash' }], result['matrix'][2]
  end

  def test_calculate_template_hash
    source1 = "{{ name }}"
    source2 = "{{ name }}"
    source3 = "{{ title }}"

    hash1 = Liquid::TemplateRecorder::JsonSchema.send(:calculate_template_hash, source1)
    hash2 = Liquid::TemplateRecorder::JsonSchema.send(:calculate_template_hash, source2)
    hash3 = Liquid::TemplateRecorder::JsonSchema.send(:calculate_template_hash, source3)

    # Same content should produce same hash
    assert_equal hash1, hash2
    
    # Different content should produce different hash
    refute_equal hash1, hash3
    
    # Should be hex string
    assert_match(/\A[a-f0-9]+\z/, hash1)
  end

  def test_invalid_json_deserialization
    invalid_json = "{ invalid json }"

    error = assert_raises(Liquid::TemplateRecorder::SchemaError) do
      Liquid::TemplateRecorder::JsonSchema.deserialize(invalid_json)
    end
    
    assert error.message.include?("Invalid JSON")
  end

  def test_optional_sections_validation
    # Test with optional sections
    data_with_optional = {
      'schema_version' => 1,
      'engine' => {
        'liquid_version' => '1.0.0',
        'ruby_version' => '3.0.0',
        'settings' => {}
      },
      'template' => {
        'source' => '{{ test }}',
        'sha256' => 'abc123'
      },
      'data' => {
        'variables' => {}
      },
      'file_system' => {
        'header' => 'content'
      },
      'filters' => [
        {
          'name' => 'upcase',
          'input' => 'test',
          'output' => 'TEST'
        }
      ],
      'metadata' => {
        'timestamp' => '2023-01-01T00:00:00Z',
        'recorder_version' => 1
      }
    }

    # Should validate successfully
    Liquid::TemplateRecorder::JsonSchema.validate_schema(data_with_optional)
  end

  def test_invalid_optional_sections
    base_data = {
      'schema_version' => 1,
      'engine' => {
        'liquid_version' => '1.0.0',
        'ruby_version' => '3.0.0',
        'settings' => {}
      },
      'template' => {
        'source' => '{{ test }}',
        'sha256' => 'abc123'
      },
      'data' => {
        'variables' => {}
      }
    }

    # Invalid file_system section
    invalid_fs_data = base_data.merge({
      'file_system' => 'not a hash'
    })

    assert_raises(Liquid::TemplateRecorder::SchemaError) do
      Liquid::TemplateRecorder::JsonSchema.validate_schema(invalid_fs_data)
    end

    # Invalid filters section
    invalid_filters_data = base_data.merge({
      'filters' => 'not an array'
    })

    assert_raises(Liquid::TemplateRecorder::SchemaError) do
      Liquid::TemplateRecorder::JsonSchema.validate_schema(invalid_filters_data)
    end
  end
end