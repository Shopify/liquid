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
      old_thread_local = Thread.current[:liquid_recorder]
      
      begin
        Thread.current[:liquid_recorder] = recorder
        
        # Monkey patch Template#render methods to inject recorder
        patch_template_rendering(recorder)
        
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
        unpatch_template_rendering
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

    private

    # Patch Template rendering methods to inject recorder
    #
    # @param recorder [Recorder] Recorder instance to inject
    def self.patch_template_rendering(recorder)
      return if @patched
      
      @patched = true
      @current_recorder = recorder
      
      # Store original methods if not already stored
      unless defined?(@original_render_method)
        @original_render_method = Liquid::Template.instance_method(:render)
        @original_render_bang_method = Liquid::Template.instance_method(:render!)
        @original_parse_method = Liquid::Template.instance_method(:parse)
      end
      
      # Patch template methods
      Liquid::Template.class_eval do
        def parse(source, options = {})
          recorder = TemplateRecorder.instance_variable_get(:@current_recorder)
          
          # Store source and registers for later use
          if recorder
            @recorded_source = source.to_s
            @parse_registers = options[:registers] || {}
          end
          
          # Call original parse method
          result = TemplateRecorder.instance_variable_get(:@original_parse_method).bind(self).call(source, options)
          
          # Capture template info
          if recorder
            recorder.set_template_info(@recorded_source, @name)
          end
          
          result
        end
        
        def render(*args)
          recorder = TemplateRecorder.instance_variable_get(:@current_recorder)
          if recorder
            # Set up context with recorder
            assigns = args[0] || {}
            options = args[1] || {}
            
            # Bind root variables BEFORE rendering
            assigns.each do |key, value|
              if value.respond_to?(:invoke_drop)
                recorder.binding_tracker.bind_root_object(value, key.to_s)
              end
            end
            
            # Inject recorder into registers, preserving both parse and render registers
            parse_registers = @parse_registers || {}
            render_registers = options[:registers] || {}
            # Merge parse registers first, then render registers, then recorder (highest priority)
            all_registers = parse_registers.merge(render_registers).merge(recorder: recorder)
            options = options.merge(registers: all_registers)
            
            # Call original render method
            result = TemplateRecorder.instance_variable_get(:@original_render_method).bind(self).call(assigns, options)
            
            # Set context info and bind root variables
            if @context
              recorder.set_context_info(@context)
            end
            
            # Capture output
            recorder.set_output(result)
            
            result
          else
            TemplateRecorder.instance_variable_get(:@original_render_method).bind(self).call(*args)
          end
        end
        
        def render!(*args)
          recorder = TemplateRecorder.instance_variable_get(:@current_recorder)
          if recorder
            # Set up context with recorder
            assigns = args[0] || {}
            options = args[1] || {}
            
            # Bind root variables BEFORE rendering
            assigns.each do |key, value|
              if value.respond_to?(:invoke_drop)
                recorder.binding_tracker.bind_root_object(value, key.to_s)
              end
            end
            
            # Inject recorder into registers, preserving both parse and render registers
            parse_registers = @parse_registers || {}
            render_registers = options[:registers] || {}
            # Merge parse registers first, then render registers, then recorder (highest priority)
            all_registers = parse_registers.merge(render_registers).merge(recorder: recorder)
            options = options.merge(registers: all_registers)
            
            # Call original render method
            result = TemplateRecorder.instance_variable_get(:@original_render_bang_method).bind(self).call(assigns, options)
            
            # Set context info and bind root variables
            if @context
              recorder.set_context_info(@context)
            end
            
            # Capture output
            recorder.set_output(result)
            
            result
          else
            TemplateRecorder.instance_variable_get(:@original_render_bang_method).bind(self).call(*args)
          end
        end
      end
    end

    # Remove Template rendering patches
    def self.unpatch_template_rendering
      return unless @patched
      
      @patched = false
      @current_recorder = nil
      
      if defined?(@original_render_method) && @original_render_method && @original_render_bang_method && @original_parse_method
        Liquid::Template.class_eval do
          define_method(:parse, TemplateRecorder.instance_variable_get(:@original_parse_method))
          define_method(:render, TemplateRecorder.instance_variable_get(:@original_render_method))
          define_method(:render!, TemplateRecorder.instance_variable_get(:@original_render_bang_method))
        end
      end
    end
  end
end