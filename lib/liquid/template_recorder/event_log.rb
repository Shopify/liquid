# frozen_string_literal: true

module Liquid
  class TemplateRecorder
    class EventLog
      def initialize
        @drop_reads = []
        @filter_calls = []
        @loop_events = []
        @file_reads = {}
      end

      # Add a drop read event
      #
      # @param path [String] Variable path where value was read
      # @param value [Object] Value that was read
      def add_drop_read(path, value)
        return unless path && serializable?(value)
        
        @drop_reads << {
          path: path,
          value: value,
          timestamp: Time.now.to_f
        }
      end

      # Add a filter call event
      #
      # @param name [String] Filter name
      # @param input [Object] Input value to filter
      # @param args [Array] Filter arguments
      # @param output [Object] Filter output
      # @param location [Hash, nil] Location information
      def add_filter_call(name, input, args, output, location = nil)
        @filter_calls << {
          name: name.to_s,
          input: input,
          args: args || [],
          output: output,
          location: location
        }
      end

      # Add a loop event
      #
      # @param type [Symbol] Event type (:enter, :item, :exit)
      # @param data [Hash] Event-specific data
      def add_loop_event(type, data = {})
        @loop_events << {
          type: type,
          data: data,
          timestamp: Time.now.to_f
        }
      end

      # Add a file read event
      #
      # @param path [String] File path that was read
      # @param content [String] File content
      def add_file_read(path, content)
        @file_reads[path] = content
      end

      # Finalize events into a minimal assigns tree
      #
      # @return [Hash] Assigns tree with nested structure
      def finalize_to_assigns_tree
        assigns = {}
        
        # Pass 1: Record non-loop property access (preserves object structure)
        @drop_reads.each do |event|
          next if is_loop_path?(event[:path])
          set_nested_value(assigns, event[:path], event[:value])
        end
        
        # Pass 2: Merge loop data into existing structure
        @drop_reads.each do |event|
          next unless is_loop_path?(event[:path])
          merge_loop_data(assigns, event[:path], event[:value])
        end
        
        # Process loop events to create arrays (legacy support)
        process_loop_events(assigns)
        
        assigns
      end

      # Get all filter calls
      #
      # @return [Array<Hash>] Filter call events
      def filter_calls
        @filter_calls.dup
      end

      # Get all file reads
      #
      # @return [Hash] File path to content mapping
      def file_reads
        @file_reads.dup
      end

      # Get statistics about recorded events
      #
      # @return [Hash] Event count statistics
      def stats
        {
          drop_reads: @drop_reads.length,
          filter_calls: @filter_calls.length,
          loop_events: @loop_events.length,
          file_reads: @file_reads.length
        }
      end

      # Clear all events (for testing)
      def clear!
        @drop_reads.clear
        @filter_calls.clear
        @loop_events.clear
        @file_reads.clear
      end

      private

      # Check if a value can be serialized to JSON
      #
      # @param value [Object] Value to check
      # @return [Boolean] True if serializable
      def serializable?(value)
        case value
        when NilClass, TrueClass, FalseClass, Numeric, String
          true
        when Array
          value.all? { |item| serializable?(item) }
        when Hash
          value.all? { |k, v| k.is_a?(String) && serializable?(v) }
        else
          false
        end
      end

      # Set a nested value in a hash using dot notation path
      #
      # @param hash [Hash] Target hash
      # @param path [String] Dot notation path (e.g., "product.variants[0].name")
      # @param value [Object] Value to set
      def set_nested_value(hash, path, value)
        return unless serializable?(value) && path && !path.empty?
        
        parts = parse_path(path)
        return if parts.empty?
        
        current = hash
        
        parts[0...-1].each do |part|
          if part[:type] == :property
            current[part[:key]] ||= {}
            current = current[part[:key]]
          elsif part[:type] == :array_access
            # Ensure array exists and has enough elements
            current[part[:key]] = [] unless current[part[:key]].is_a?(Array)
            array = current[part[:key]]
            
            # Extend array if needed
            while array.length <= part[:index]
              array << {}
            end
            
            current = array[part[:index]]
          end
        end
        
        # Set the final value
        final_part = parts.last
        if final_part[:type] == :property
          # Defensive check - ensure current supports hash-like access
          if current.is_a?(Hash)
            current[final_part[:key]] = value
          elsif current.respond_to?(:[]=) && !current.is_a?(Array)
            current[final_part[:key]] = value
          else
            # Cannot set property on this type of object
            return
          end
        elsif final_part[:type] == :array_access
          # Defensive check - ensure current supports hash-like access
          if current.is_a?(Hash)
            current[final_part[:key]] = [] unless current[final_part[:key]].is_a?(Array)
            array = current[final_part[:key]]
            
            while array.length <= final_part[:index]
              array << nil
            end
            
            array[final_part[:index]] = value
          else
            # Cannot set array property on this type of object
            return
          end
        end
      end

      # Parse a path string into components
      #
      # @param path [String] Path like "product.variants[0].name"
      # @return [Array<Hash>] Array of path components
      def parse_path(path)
        parts = []
        current_key = ""
        i = 0
        
        while i < path.length
          char = path[i]
          
          case char
          when '.'
            if !current_key.empty?
              parts << { type: :property, key: current_key }
              current_key = ""
            end
          when '['
            if !current_key.empty?
              # Find the closing bracket
              end_bracket = path.index(']', i)
              if end_bracket
                index = path[i + 1...end_bracket].to_i
                parts << { type: :array_access, key: current_key, index: index }
                current_key = ""
                i = end_bracket
              else
                current_key += char
              end
            else
              current_key += char
            end
          else
            current_key += char
          end
          
          i += 1
        end
        
        if !current_key.empty?
          parts << { type: :property, key: current_key }
        end
        
        parts
      end

      # Process loop events to ensure proper array structure
      #
      # @param assigns [Hash] Assigns tree to modify
      def process_loop_events(assigns)
        loop_stack = []
        
        @loop_events.each do |event|
          case event[:type]
          when :enter
            loop_stack.push(event[:data])
          when :exit
            loop_stack.pop
          when :item
            # Ensure array structure exists for loop items
            if !loop_stack.empty?
              current_loop = loop_stack.last
              if current_loop && current_loop[:collection_path]
                ensure_array_structure(assigns, current_loop[:collection_path])
              end
            end
          end
        end
      end

      # Ensure an array structure exists at the given path
      #
      # @param hash [Hash] Target hash
      # @param path [String] Path to ensure as array
      def ensure_array_structure(hash, path)
        parts = parse_path(path)
        current = hash
        
        parts.each do |part|
          if part[:type] == :property
            if parts.last == part
              # This is the final part - make it an array
              current[part[:key]] ||= []
            else
              current[part[:key]] ||= {}
              current = current[part[:key]]
            end
          end
        end
      end

      # Check if a path represents loop-based access
      #
      # @param path [String] Path to check
      # @return [Boolean] True if path contains array indexing
      def is_loop_path?(path)
        path&.include?('[') && path&.include?(']')
      end

      # Merge loop data into existing assigns structure
      #
      # @param assigns [Hash] Target assigns hash
      # @param path [String] Path with array indexing (e.g., "categories[0].name")
      # @param value [Object] Value to set
      def merge_loop_data(assigns, path, value)
        # Use the existing set_nested_value method but with better error handling
        set_nested_value(assigns, path, value)
      rescue => e
        # If there's a conflict, log it but continue
        # This can happen with complex nested structures
        warn "Warning: Could not merge loop data for path '#{path}': #{e.message}"
      end
    end
  end
end