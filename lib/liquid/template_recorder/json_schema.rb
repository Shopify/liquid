# frozen_string_literal: true

require 'json'
require 'digest/sha2'
require 'set'

module Liquid
  class TemplateRecorder
    class JsonSchema
      SCHEMA_VERSION = 1
      RECORDER_VERSION = 1

      # Serialize recording data to JSON
      #
      # @param recording_data [Hash] Recording data from Recorder#finalize_recording
      # @return [String] Pretty-printed JSON string
      def self.serialize(recording_data)
        # Ensure all data is serializable
        sanitized_data = ensure_serializable(recording_data)
        
        # Generate stable, pretty-printed JSON
        JSON.pretty_generate(sanitized_data, {
          indent: "  ",
          object_nl: "\n",
          array_nl: "\n"
        })
      end

      # Deserialize JSON string to recording data
      #
      # @param json_string [String] JSON recording content
      # @return [Hash] Parsed recording data
      def self.deserialize(json_string)
        JSON.parse(json_string)
      rescue JSON::ParserError => e
        raise SchemaError, "Invalid JSON in recording file: #{e.message}"
      end

      # Validate recording data schema
      #
      # @param data [Hash] Recording data to validate
      # @raise [SchemaError] If schema is invalid
      def self.validate_schema(data)
        unless data.is_a?(Hash)
          raise SchemaError, "Recording data must be a hash"
        end

        # Check required top-level fields
        required_fields = %w[schema_version engine template data]
        required_fields.each do |field|
          unless data.key?(field)
            raise SchemaError, "Missing required field: #{field}"
          end
        end

        # Validate schema version
        unless data['schema_version'] == SCHEMA_VERSION
          raise SchemaError, "Unsupported schema version: #{data['schema_version']}, expected: #{SCHEMA_VERSION}"
        end

        # Validate engine info
        validate_engine_section(data['engine'])
        
        # Validate template info
        validate_template_section(data['template'])
        
        # Validate data section
        validate_data_section(data['data'])
        
        # Validate optional sections
        validate_file_system_section(data['file_system']) if data['file_system']
        validate_filters_section(data['filters']) if data['filters']
        validate_metadata_section(data['metadata']) if data['metadata']
      end

      # Build complete recording data structure
      #
      # @param template_source [String] Template source code
      # @param assigns [Hash] Variable assignments
      # @param file_reads [Hash] File path to content mapping
      # @param filter_calls [Array] Filter call log
      # @param output [String, nil] Final rendered output
      # @param entrypoint [String, nil] Template entrypoint path
      # @return [Hash] Complete recording data structure
      def self.build_recording_data(template_source:, assigns:, file_reads:, filter_calls:, output: nil, entrypoint: nil)
        {
          'schema_version' => SCHEMA_VERSION,
          'engine' => {
            'liquid_version' => Liquid::VERSION,
            'ruby_version' => RUBY_VERSION,
            'settings' => {
              'strict_variables' => false,
              'strict_filters' => false,
              'error_mode' => 'lax'
            }
          },
          'template' => {
            'source' => template_source,
            'entrypoint' => entrypoint,
            'sha256' => calculate_template_hash(template_source)
          },
          'data' => {
            'variables' => ensure_serializable(assigns)
          },
          'file_system' => file_reads,
          'filters' => filter_calls,
          'output' => output ? { 'string' => output } : nil,
          'metadata' => {
            'timestamp' => Time.now.utc.iso8601,
            'recorder_version' => RECORDER_VERSION
          }
        }.compact
      end

      private

      # Ensure an object contains only serializable types
      #
      # @param obj [Object] Object to sanitize
      # @param visited [Set] Set of visited object IDs to prevent infinite recursion
      # @return [Object] Serializable version of object
      def self.ensure_serializable(obj, visited = Set.new)
        return "[Circular]" if visited.include?(obj.object_id)
        
        case obj
        when NilClass, TrueClass, FalseClass, Numeric, String
          obj
        when Array
          visited.add(obj.object_id)
          result = obj.map { |item| ensure_serializable(item, visited) }
          visited.delete(obj.object_id)
          result
        when Hash
          visited.add(obj.object_id)
          result = {}
          obj.each do |key, value|
            # Ensure keys are strings
            string_key = key.to_s
            result[string_key] = ensure_serializable(value, visited)
          end
          visited.delete(obj.object_id)
          result
        else
          # Convert non-serializable objects to strings
          obj.to_s
        end
      end

      # Calculate SHA256 hash of template source
      #
      # @param source [String] Template source code
      # @return [String] Hex-encoded SHA256 hash
      def self.calculate_template_hash(source)
        Digest::SHA256.hexdigest(source)
      end

      # Validate engine section
      #
      # @param engine [Hash] Engine information
      def self.validate_engine_section(engine)
        unless engine.is_a?(Hash)
          raise SchemaError, "Engine section must be a hash"
        end

        required_fields = %w[liquid_version ruby_version settings]
        required_fields.each do |field|
          unless engine.key?(field)
            raise SchemaError, "Engine missing required field: #{field}"
          end
        end
      end

      # Validate template section
      #
      # @param template [Hash] Template information
      def self.validate_template_section(template)
        unless template.is_a?(Hash)
          raise SchemaError, "Template section must be a hash"
        end

        unless template.key?('source') && template['source'].is_a?(String)
          raise SchemaError, "Template must have source field as string"
        end

        unless template.key?('sha256') && template['sha256'].is_a?(String)
          raise SchemaError, "Template must have sha256 field as string"
        end
      end

      # Validate data section
      #
      # @param data [Hash] Data section
      def self.validate_data_section(data)
        unless data.is_a?(Hash)
          raise SchemaError, "Data section must be a hash"
        end

        unless data.key?('variables')
          raise SchemaError, "Data section missing variables field"
        end

        variables = data['variables']
        unless variables.is_a?(Hash)
          raise SchemaError, "Variables must be a hash"
        end

        # Validate that variables contain only serializable types
        validate_serializable_structure(variables, 'data.variables')
      end

      # Validate file system section
      #
      # @param file_system [Hash] File system mapping
      def self.validate_file_system_section(file_system)
        unless file_system.is_a?(Hash)
          raise SchemaError, "File system section must be a hash"
        end

        file_system.each do |path, content|
          unless path.is_a?(String) && content.is_a?(String)
            raise SchemaError, "File system entries must be string path to string content"
          end
        end
      end

      # Validate filters section
      #
      # @param filters [Array] Filter call log
      def self.validate_filters_section(filters)
        unless filters.is_a?(Array)
          raise SchemaError, "Filters section must be an array"
        end

        filters.each_with_index do |filter, index|
          unless filter.is_a?(Hash)
            raise SchemaError, "Filter #{index} must be a hash"
          end

          required_fields = %w[name input output]
          required_fields.each do |field|
            unless filter.key?(field)
              raise SchemaError, "Filter #{index} missing required field: #{field}"
            end
          end
        end
      end

      # Validate metadata section
      #
      # @param metadata [Hash] Metadata information
      def self.validate_metadata_section(metadata)
        unless metadata.is_a?(Hash)
          raise SchemaError, "Metadata section must be a hash"
        end

        if metadata.key?('recorder_version') && !metadata['recorder_version'].is_a?(Integer)
          raise SchemaError, "Metadata recorder_version must be an integer"
        end
      end

      # Validate that a structure contains only serializable types
      #
      # @param obj [Object] Object to validate
      # @param path [String] Path for error reporting
      def self.validate_serializable_structure(obj, path)
        case obj
        when NilClass, TrueClass, FalseClass, Numeric, String
          # Valid scalars
        when Array
          obj.each_with_index do |item, index|
            validate_serializable_structure(item, "#{path}[#{index}]")
          end
        when Hash
          obj.each do |key, value|
            unless key.is_a?(String)
              raise SchemaError, "Hash keys must be strings at #{path}"
            end
            validate_serializable_structure(value, "#{path}.#{key}")
          end
        else
          raise SchemaError, "Non-serializable type #{obj.class} at #{path}"
        end
      end
    end
  end
end