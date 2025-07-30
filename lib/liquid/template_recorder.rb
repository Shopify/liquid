# frozen_string_literal: true

require_relative 'template_recorder/recorder'
require_relative 'template_recorder/replayer'
require_relative 'template_recorder/memory_file_system'
require_relative 'template_recorder/binding_tracker'
require_relative 'template_recorder/event_log'
require_relative 'template_recorder/json_schema'

module Liquid
  class TemplateRecorder
    class RecorderError < StandardError; end
    class ReplayError < StandardError; end
    class SchemaError < StandardError; end

    # Primary recording API
    # Records template execution to a JSON file
    #
    # @param filename [String] Path to output JSON recording file
    # @yield Block containing template execution to record
    # @return [String] Path to the created recording file
    def self.record(filename, &block)
      raise ArgumentError, "Block required for recording" unless block_given?
      
      recorder = create_recorder
      
      begin
        # Set up recording context globally for file systems and clean API wrapper
        old_thread_local = Thread.current[:liquid_recorder]
        Thread.current[:liquid_recorder] = recorder
        
        # Install clean recording wrapper
        recording_wrapper = RecordingWrapper.new(recorder)
        recording_wrapper.install
        
        # Execute the block with recording active
        result = block.call
        
        # Capture final output if it's a string
        recorder.set_output(result) if result.is_a?(String)
        
        # Finalize recording and write to file (only on success)
        recording_data = recorder.finalize_recording
        json_output = JsonSchema.serialize(recording_data)
        
        File.write(filename, json_output)
        filename
      rescue => e
        # Don't write file on error - clean up if it was partially created
        File.delete(filename) if File.exist?(filename)
        raise e
      ensure
        Thread.current[:liquid_recorder] = old_thread_local
        recording_wrapper&.uninstall
      end
    end

    # Primary replay API
    # Creates a replayer from a JSON recording file
    #
    # @param filename [String] Path to JSON recording file
    # @param mode [Symbol] Replay mode (:compute, :strict, :verify)
    # @return [Replayer] Configured replayer instance
    def self.replay_from(filename, mode: :compute)
      unless File.exist?(filename)
        raise ReplayError, "Recording file not found: #{filename}"
      end
      
      json_content = File.read(filename)
      recording_data = JsonSchema.deserialize(json_content)
      create_replayer(recording_data, mode)
    end

    # Internal factory method for creating recorder instances
    #
    # @return [Recorder] New recorder instance
    def self.create_recorder
      Recorder.new
    end

    # Internal factory method for creating replayer instances
    #
    # @param data [Hash] Deserialized recording data
    # @param mode [Symbol] Replay mode
    # @return [Replayer] Configured replayer instance
    def self.create_replayer(data, mode)
      JsonSchema.validate_schema(data)
      Replayer.new(data, mode)
    end

    # Clean recording wrapper that intercepts Template methods without monkey patching
    class RecordingWrapper
      def initialize(recorder)
        @recorder = recorder
        @original_template_parse = nil
        @installed = false
      end
      
      def install
        return if @installed
        @installed = true
        
        # Store original class method
        @original_template_parse = Liquid::Template.method(:parse)
        
        # Create wrapper for Template.parse that injects recording setup
        recorder = @recorder
        original_parse = @original_template_parse
        Liquid::Template.define_singleton_method(:parse) do |source, options = {}|
          # Parse template normally using original method
          template = original_parse.call(source, options)
          
          # Capture template info
          recorder.set_template_info(source.to_s, template.name)
          
          # Wrap the template to inject recorder during render
          TemplateRecorder::RecordingTemplate.new(template, recorder)
        end
      end
      
      def uninstall
        return unless @installed
        @installed = false
        
        if @original_template_parse
          Liquid::Template.define_singleton_method(:parse, @original_template_parse)
        end
      end
    end
    
    # Template wrapper that maintains API compatibility while injecting recording
    class RecordingTemplate
      def initialize(template, recorder)
        @template = template
        @recorder = recorder
      end
      
      # Delegate all methods to wrapped template except render methods
      def method_missing(method, *args, &block)
        @template.send(method, *args, &block)
      end
      
      def respond_to_missing?(method, include_private = false)
        @template.respond_to?(method, include_private)
      end
      
      # Override render to inject recorder into context
      def render(*args)
        assigns = args[0] || {}
        options = args[1] || {}
        
        # Store and wrap original assigns for recording
        @recorder.store_original_assigns(assigns)
        
        # Use the wrapped assigns for rendering so we can track access
        wrapped_assigns = @recorder.instance_variable_get(:@original_assigns)
        
        # Bind root variables BEFORE rendering
        wrapped_assigns.each do |key, value|
          if value.respond_to?(:invoke_drop)
            @recorder.binding_tracker.bind_root_object(value, key.to_s)
          else
            # Also bind regular hash/array variables for semantic key generation
            @recorder.binding_tracker.bind_root_object(value, key.to_s)
          end
        end
        
        # Merge registers from parse, render, and recorder
        parse_registers = @template.instance_variable_get(:@options)&.[](:registers) || {}
        render_registers = options[:registers] || {}
        all_registers = parse_registers.merge(render_registers).merge(recorder: @recorder)
        options = options.merge(registers: all_registers)
        
        # Render template with wrapped assigns
        result = @template.render(wrapped_assigns, options)
        
        # Set context info from template's context after rendering
        if @template.instance_variable_get(:@context)
          @recorder.set_context_info(@template.instance_variable_get(:@context))
        end
        
        # Capture output
        @recorder.set_output(result)
        
        result
      end
      
      def render!(*args)
        assigns = args[0] || {}
        options = args[1] || {}
        
        # Store and wrap original assigns for recording  
        @recorder.store_original_assigns(assigns)
        
        # Use the wrapped assigns for rendering so we can track access
        wrapped_assigns = @recorder.instance_variable_get(:@original_assigns)
        
        # Bind root variables BEFORE rendering
        wrapped_assigns.each do |key, value|
          if value.respond_to?(:invoke_drop)
            @recorder.binding_tracker.bind_root_object(value, key.to_s)
          end
        end
        
        # Merge registers from parse, render, and recorder
        parse_registers = @template.instance_variable_get(:@options)&.[](:registers) || {}
        render_registers = options[:registers] || {}
        all_registers = parse_registers.merge(render_registers).merge(recorder: @recorder)
        options = options.merge(registers: all_registers)
        
        # Render template with wrapped assigns
        result = @template.render!(wrapped_assigns, options)
        
        # Set context info from template's context after rendering
        if @template.instance_variable_get(:@context)
          @recorder.set_context_info(@template.instance_variable_get(:@context))
        end
        
        # Capture output
        @recorder.set_output(result)
        
        result
      end
    end

    private
  end
end