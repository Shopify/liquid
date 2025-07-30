# frozen_string_literal: true

module Liquid
  class TemplateRecorder
    class Replayer
      def initialize(recording_data, mode = :compute)
        @data = recording_data
        @mode = mode.to_sym
        @memory_fs = MemoryFileSystem.new(@data['file_system'])
        @filter_index = 0
        
        validate_mode!
        validate_engine_compatibility
      end

      # Render the recorded template
      #
      # @param to [String, nil] Optional file path to write output
      # @return [String] Rendered output
      def render(to: nil)
        assigns = deep_copy(@data['data']['variables'])
        
        # Parse template
        template = Liquid::Template.parse(@data['template']['source'], 
          registers: build_registers)
        
        # Configure context for replay mode
        context_options = build_context_options
        
        # Render template
        output = template.render!(assigns, context_options)
        
        # Verify output if requested
        verify_output(output) if @mode == :verify
        
        # Write to file if requested
        File.write(to, output) if to
        
        output
      end

      # Get replay statistics
      #
      # @return [Hash] Replay information
      def stats
        {
          mode: @mode,
          template_size: @data['template']['source'].length,
          variables_count: count_nested_keys(@data['data']['variables']),
          files_count: @data['file_system']&.length || 0,
          filters_count: @data['filters']&.length || 0
        }
      end

      # Get template information
      #
      # @return [Hash] Template metadata
      def template_info
        {
          source: @data['template']['source'],
          entrypoint: @data['template']['entrypoint'],
          sha256: @data['template']['sha256']
        }
      end

      private

      # Validate replay mode
      def validate_mode!
        valid_modes = [:compute, :strict, :verify]
        unless valid_modes.include?(@mode)
          raise ReplayError, "Invalid replay mode: #{@mode}. Must be one of: #{valid_modes.join(', ')}"
        end
      end

      # Validate engine compatibility and warn on version mismatches
      def validate_engine_compatibility
        return unless @data['engine']
        
        recorded_version = @data['engine']['liquid_version']
        current_version = Liquid::VERSION
        
        if recorded_version != current_version
          warn "Warning: Recording was made with Liquid #{recorded_version}, " \
               "but replaying with Liquid #{current_version}. " \
               "Results may differ in :compute mode."
        end
      end

      # Build registers for template parsing
      #
      # @return [Hash] Registers hash
      def build_registers
        registers = {
          file_system: @memory_fs
        }
        
        # Add strict filter strainer for strict mode
        if @mode == :strict
          registers[:strict_filter_replayer] = self
        end
        
        registers
      end

      # Build context options for rendering
      #
      # @return [Hash] Context options
      def build_context_options
        options = {}
        
        # Apply recorded engine settings if available
        if @data['engine'] && @data['engine']['settings']
          settings = @data['engine']['settings']
          options[:strict_variables] = settings['strict_variables'] if settings.key?('strict_variables')
          options[:strict_filters] = settings['strict_filters'] if settings.key?('strict_filters')
        end
        
        # Override for strict mode
        if @mode == :strict
          options[:strainer_class] = create_strict_strainer_class
        end
        
        options
      end

      # Create a strainer class that replays recorded filter outputs
      #
      # @return [Class] Strainer class for strict replay
      def create_strict_strainer_class
        replayer = self
        
        Class.new(Liquid::StrainerTemplate) do
          define_method :initialize do |context|
            super(context)
            @replayer = replayer
          end
          
          define_method :invoke do |method, *args|
            @replayer.replay_next_filter(method, args.first, args[1..-1] || [])
          end
        end
      end

      # Replay the next filter call in strict mode
      #
      # @param method [String] Filter method name
      # @param input [Object] Filter input
      # @param args [Array] Filter arguments
      # @return [Object] Recorded filter output
      def replay_next_filter(method, input, args)
        filters = @data['filters'] || []
        
        if @filter_index >= filters.length
          raise ReplayError, "No more recorded filter calls available for #{method}"
        end
        
        recorded_call = filters[@filter_index]
        @filter_index += 1
        
        # Verify filter call matches recording
        if recorded_call['name'] != method.to_s
          raise ReplayError, "Filter mismatch: expected #{recorded_call['name']}, got #{method}"
        end
        
        # Optionally verify input and args
        if input != recorded_call['input']
          warn "Warning: Filter input mismatch for #{method}. " \
               "Expected: #{recorded_call['input'].inspect}, " \
               "Got: #{input.inspect}"
        end
        
        if args != recorded_call['args']
          warn "Warning: Filter args mismatch for #{method}. " \
               "Expected: #{recorded_call['args'].inspect}, " \
               "Got: #{args.inspect}"
        end
        
        recorded_call['output']
      end

      # Verify output matches recorded output
      #
      # @param actual_output [String] Actual rendered output
      def verify_output(actual_output)
        return unless @data['output'] && @data['output']['string']
        
        expected_output = @data['output']['string']
        
        if actual_output != expected_output
          puts "Output verification FAILED"
          puts "Expected length: #{expected_output.length}"
          puts "Actual length: #{actual_output.length}"
          
          # Show first difference
          expected_output.chars.each_with_index do |char, i|
            if i >= actual_output.length || actual_output[i] != char
              puts "First difference at position #{i}:"
              puts "Expected: #{char.inspect}"
              puts "Actual: #{actual_output[i]&.inspect || 'EOF'}"
              break
            end
          end
          
          raise ReplayError, "Output verification failed"
        else
          puts "Output verification PASSED"
        end
      end

      # Create a deep copy of an object
      #
      # @param obj [Object] Object to copy
      # @return [Object] Deep copy
      def deep_copy(obj)
        case obj
        when Hash
          result = {}
          obj.each { |k, v| result[k] = deep_copy(v) }
          result
        when Array
          obj.map { |item| deep_copy(item) }
        else
          obj
        end
      end

      # Count nested keys in a hash structure
      #
      # @param obj [Object] Object to count keys in
      # @return [Integer] Total number of keys
      def count_nested_keys(obj)
        case obj
        when Hash
          obj.keys.length + obj.values.sum { |v| count_nested_keys(v) }
        when Array
          obj.sum { |item| count_nested_keys(item) }
        else
          0
        end
      end
    end
  end
end