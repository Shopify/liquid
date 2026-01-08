# frozen_string_literal: true

module Liquid
  class TemplateRecorder
    class Recorder
      attr_reader :event_log, :binding_tracker, :filter_patterns

      def initialize
        @event_log = EventLog.new
        @binding_tracker = BindingTracker.new
        @template_info = {}
        @context_info = {}
        @last_output = nil
        @filter_call_counter = 0
        @filter_patterns = {}  # semantic_key => result
        @original_assigns = {}  # Store the original variable assignments
      end

      # Record a drop property access
      #
      # @param drop_object [Liquid::Drop] The drop being accessed
      # @param method_name [String, Symbol] Property/method name
      # @param result [Object] The returned value
      def emit_drop_read(drop_object, method_name, result)
        return unless drop_object && method_name

        # Build the property access path
        property_path = @binding_tracker.build_property_path(drop_object, method_name.to_s)
        
        if property_path
          # Record the read at the resolved path
          @event_log.add_drop_read(property_path, result)
          
          # If result is also a Drop, bind it for future property access
          if result.respond_to?(:invoke_drop)
            @binding_tracker.bind_root_object(result, property_path)
          end
        end
      end

      # Generate a semantic key for a filter call
      #
      # @param filter_name [String] Name of the filter
      # @param input [Object] Input value to the filter
      # @param args [Array] Filter arguments
      # @return [String] Semantic key for this filter invocation
      def generate_filter_key(filter_name, input, args)
        # Try to get semantic path for the input object
        input_path = nil
        
        if input.respond_to?(:object_id)
          # For Drop objects, try to resolve their binding path
          if input.respond_to?(:invoke_drop)
            input_path = @binding_tracker.resolve_binding_path(input)
          elsif input.is_a?(String) || input.is_a?(Numeric) || input.is_a?(TrueClass) || input.is_a?(FalseClass) || input.nil?
            # For simple values, use the value itself (truncated if long)
            input_path = input.nil? ? "nil" : input.to_s.length > 50 ? "#{input.to_s[0..47]}..." : input.to_s
          else
            # For other objects, try to resolve binding path
            input_path = @binding_tracker.resolve_binding_path(input)
          end
        end
        
        # Fallback to execution order if we can't resolve a semantic path
        unless input_path
          input_path = "input_#{@filter_call_counter}"
        end
        
        # Create the base semantic key
        key_parts = [input_path, filter_name]
        
        # Add arguments if present
        if args && !args.empty?
          arg_str = args.map { |arg| 
            case arg
            when String, Numeric, TrueClass, FalseClass, NilClass
              arg.inspect
            else
              arg.to_s.length > 20 ? "#{arg.to_s[0..17]}..." : arg.to_s
            end
          }.join(',')
          key_parts << "(#{arg_str})"
        end
        
        # Add loop context if we're in a loop
        if @binding_tracker.loop_depth > 0
          key_parts << "loop_depth_#{@binding_tracker.loop_depth}"
        end
        
        # Add execution counter to ensure uniqueness
        semantic_key = "#{key_parts.join('|')}[#{@filter_call_counter}]"
        
        @filter_call_counter += 1
        semantic_key
      end

      # Create a summary of an object for recording (avoiding huge serializations)
      #
      # @param obj [Object] Object to summarize
      # @return [Object] Summarized representation
      def summarize_object(obj)
        case obj
        when nil, Numeric, TrueClass, FalseClass
          obj
        when String
          # Truncate long strings to save space
          obj.length > 100 ? "#{obj[0..97]}..." : obj
        when Array
          # For arrays, show first few items and count
          if obj.length <= 3
            obj.map { |item| summarize_object(item) }
          else
            [
              summarize_object(obj[0]),
              summarize_object(obj[1]),
              "... (#{obj.length - 2} more items)"
            ]
          end
        when Hash
          # For hashes, show a few key entries
          if obj.length <= 3
            obj.transform_values { |v| summarize_object(v) }
          else
            summary = {}
            obj.first(2).each { |k, v| summary[k] = summarize_object(v) }
            summary["..."] = "(#{obj.length - 2} more keys)"
            summary
          end
        else
          # For other objects, try to get a meaningful summary
          if obj.respond_to?(:invoke_drop)
            path = @binding_tracker.resolve_binding_path(obj)
            path || obj.class.name
          elsif obj.respond_to?(:to_liquid)
            "#{obj.class.name}(liquid_compatible)"
          else
            obj.class.name
          end
        end
      end

      # Record a filter call
      #
      # @param name [String, Symbol] Filter name
      # @param input [Object] Input value
      # @param args [Array] Filter arguments
      # @param output [Object] Filter output
      # @param location [Hash, nil] Location information
      def emit_filter_call(name, input, args, output, location = nil)
        # Generate semantic key for this filter call
        semantic_key = generate_filter_key(name.to_s, input, args)
        
        # Store the pattern and result with compressed output
        @filter_patterns[semantic_key] = {
          filter_name: name.to_s,
          input_summary: summarize_object(input),
          args: (args || []).map { |arg| summarize_object(arg) },
          output: summarize_object(output),
          location: location
        }
        
        # Add to event log with reference (optimized format only)
        @event_log.add_filter_call_optimized(semantic_key, name.to_s, location)
      end

      # Record a file read operation
      #
      # @param path [String] File path that was read
      # @param content [String] File content
      def emit_file_read(path, content)
        @event_log.add_file_read(path, content)
      end

      # Record entering a for loop
      #
      # @param collection_expr [String] Collection expression string
      # @param variable_name [String] Loop variable name (e.g., "category", "item")
      def for_enter(collection_expr, variable_name = nil)
        # Try to resolve the collection path from current context
        collection_path = resolve_collection_path(collection_expr)
        
        
        @binding_tracker.enter_loop(collection_path, variable_name)
        @event_log.add_loop_event(:enter, {
          collection_expr: collection_expr,
          collection_path: collection_path,
          variable_name: variable_name
        })
      end

      # Record a for loop item
      #
      # @param index [Integer] Loop index
      # @param item [Object] Loop item
      def for_item(index, item)
        @binding_tracker.bind_current_loop_item(index, item)
        @event_log.add_loop_event(:item, {
          index: index,
          item_object_id: item&.object_id
        })
      end

      # Record exiting a for loop
      def for_exit
        loop_context = @binding_tracker.exit_loop
        @event_log.add_loop_event(:exit, loop_context || {})
      end

      # Set template information for recording
      #
      # @param source [String] Template source code
      # @param entrypoint [String, nil] Template entrypoint path
      def set_template_info(source, entrypoint = nil)
        @template_info = {
          source: source,
          entrypoint: entrypoint
        }
      end

      # Set context information for recording
      #
      # @param context [Liquid::Context] Liquid context
      def set_context_info(context)
        return unless context
        
        @context_info = {
          strict_variables: context.strict_variables || false,
          strict_filters: context.strict_filters || false
        }
        
        # Bind root-level variables from context environments
        bind_context_variables(context)
      end

      # Set the final output of template rendering
      #
      # @param output [String] Rendered output
      def set_output(output)
        @last_output = output
      end

      # Finalize the recording and return complete data structure
      #
      # @return [Hash] Complete recording data ready for JSON serialization
      def finalize_recording
        # Start with original assigns, then merge any dynamic Drop data
        assigns = @original_assigns.dup
        dynamic_assigns = @event_log.finalize_to_assigns_tree
        
        # Merge dynamic data into original assigns, but preserve original types when dynamic is empty
        assigns = smart_merge(assigns, dynamic_assigns)
        
        # Unwrap trackable objects for JSON serialization
        assigns = unwrap_trackable_objects(assigns)
        
        JsonSchema.build_recording_data(
          template_source: @template_info[:source] || "",
          assigns: assigns,
          file_reads: @event_log.file_reads,
          filter_calls: [],  # Empty - using optimized filter_patterns instead
          filter_patterns: @filter_patterns,
          output: @last_output,
          entrypoint: @template_info[:entrypoint]
        )
      end

      # Get recording statistics
      #
      # @return [Hash] Recording statistics
      def stats
        @event_log.stats.merge({
          bindings: @binding_tracker.current_bindings.length,
          loop_depth: @binding_tracker.loop_depth
        })
      end

      # Store original template assigns
      #
      # @param assigns [Hash] Original variable assignments passed to template.render
      def store_original_assigns(assigns)
        # Convert regular Hash/Array objects to trackable Drop-like objects
        @original_assigns = {}
        assigns.each do |key, value|
          @original_assigns[key] = wrap_value_for_tracking(value, key)
        end
      end

      # Wrap a value to make it trackable during liquid rendering
      def wrap_value_for_tracking(value, path)
        case value
        when Liquid::Drop
          # Drop objects are trackable by the original system, but we need to extract
          # their complete underlying data for hermetic recording
          if value.respond_to?(:instance_variable_get)
            # Try to get the underlying data from common instance variable patterns
            underlying_data = nil
            [:@data, :@object, :@product, :@item].each do |var|
              if value.instance_variables.include?(var)
                underlying_data = value.instance_variable_get(var)
                break if underlying_data.is_a?(Hash)
              end
            end
            
            if underlying_data.is_a?(Hash)
              # Wrap the underlying hash data for tracking, but also preserve the Drop
              # This ensures both property access AND json serialization work correctly
              underlying_data.dup
            else
              value
            end
          else
            value
          end
        when Hash
          # Create a trackable hash wrapper
          TrackableHash.new(value, path, self)
        when Array
          # Create a trackable array wrapper  
          TrackableArray.new(value, path, self)
        when String, Numeric, TrueClass, FalseClass, NilClass
          # Return primitive values directly - they don't need wrapping
          value
        else
          # For other objects, try to extract serializable data
          if value.respond_to?(:to_h) && !value.to_h.empty?
            wrap_value_for_tracking(value.to_h, path)
          elsif value.respond_to?(:to_a) && !value.to_a.empty?
            wrap_value_for_tracking(value.to_a, path)
          elsif value.respond_to?(:invoke_drop)
            # This is likely a Drop-like object - pass it through as-is
            value
          else
            # For unknown objects, return their string representation
            value.to_s
          end
        end
      end

      # Deep merge two hashes
      def deep_merge(hash1, hash2)
        result = hash1.dup
        hash2.each do |key, value|
          if result[key].is_a?(Hash) && value.is_a?(Hash)
            result[key] = deep_merge(result[key], value)
          else
            result[key] = value
          end
        end
        result
      end

      # Smart merge that preserves original structure when dynamic data is empty/irrelevant
      def smart_merge(original, dynamic)
        result = original.dup
        dynamic.each do |key, value|
          if original[key].is_a?(Hash) && value.is_a?(Array)
            # NEVER replace a Hash with an Array - this is always wrong
            # This happens when loop events incorrectly create array structures
            # for variables that should remain as objects
            result[key] = original[key]
          elsif original[key].is_a?(Hash) && value.is_a?(Hash)
            result[key] = deep_merge(original[key], value)
          elsif value.nil? || (value.is_a?(Array) && value.empty?) || (value.is_a?(Hash) && value.empty?)
            # Keep original if dynamic value is empty/nil
            result[key] = original[key] if original.key?(key)
          else
            result[key] = value
          end
        end
        result
      end

      # Unwrap trackable objects to extract their underlying data for JSON serialization
      def unwrap_trackable_objects(obj)
        case obj
        when TrackableHash
          # Extract the underlying hash and recursively unwrap its contents
          unwrapped = {}
          obj.instance_variable_get(:@hash).each do |key, value|
            unwrapped[key] = unwrap_trackable_objects(value)
          end
          unwrapped
        when TrackableArray
          # Extract the underlying array and recursively unwrap its contents
          obj.instance_variable_get(:@array).map do |item|
            unwrap_trackable_objects(item)
          end
        when Hash
          # Recursively unwrap hash values
          result = {}
          obj.each do |key, value|
            result[key] = unwrap_trackable_objects(value)
          end
          result
        when Array
          # Recursively unwrap array items
          obj.map { |item| unwrap_trackable_objects(item) }
        else
          # For other objects (including Drop objects), try to extract serializable data
          if obj.is_a?(Liquid::Drop)
            # For Drop objects, try to extract the underlying data
            if obj.respond_to?(:instance_variable_get)
              # Try to get the underlying data from common instance variable patterns
              underlying_data = nil
              [:@data, :@object, :@product, :@item].each do |var|
                if obj.instance_variables.include?(var)
                  underlying_data = obj.instance_variable_get(var)
                  break if underlying_data.is_a?(Hash)
                end
              end
              
              if underlying_data.is_a?(Hash)
                unwrap_trackable_objects(underlying_data)
              else
                obj
              end
            else
              obj
            end
          elsif obj.respond_to?(:to_h) && !obj.to_h.empty?
            unwrap_trackable_objects(obj.to_h)
          elsif obj.respond_to?(:to_a) && !obj.to_a.empty?
            obj.to_a.map { |item| unwrap_trackable_objects(item) }
          else
            # Return primitive values and unserializable objects as-is
            obj
          end
        end
      end

      # Simple copy that handles basic data types but avoids complex object trees
      def simple_copy(obj)
        case obj
        when Hash
          # Only copy serializable hash values to JSON-safe types
          result = {}
          obj.each do |k, v|
            if serializable_type?(v)
              result[k] = simple_copy(v)
            else
              # Skip complex objects that might have circular references
              result[k] = v.class.name
            end
          end
          result
        when Array
          obj.map { |item| simple_copy(item) }
        when String, Numeric, TrueClass, FalseClass, NilClass
          obj
        else
          # For other types, just store the class name to avoid circular references
          obj.class.name
        end
      end

      # Check if a type is safe to serialize/copy
      def serializable_type?(obj)
        case obj
        when String, Numeric, TrueClass, FalseClass, NilClass
          true
        when Hash
          obj.all? { |k, v| k.is_a?(String) && serializable_type?(v) }
        when Array
          obj.all? { |item| serializable_type?(item) }
        else
          false
        end
      end

      # Trackable Hash wrapper that records property access
      class TrackableHash
        def initialize(hash, path, recorder)
          @hash = hash
          @path = path
          @recorder = recorder
        end

        # Intercept [] access to record reads
        def [](key)
          value = @hash[key]
          full_path = "#{@path}.#{key}"
          
          # Record the access
          @recorder.emit_drop_read(self, key, value)
          
          # Wrap nested values for continued tracking
          @recorder.wrap_value_for_tracking(value, full_path)
        end

        # Support liquid property access
        def invoke_drop(method_name)
          self[method_name.to_s]
        end

        # Forward other methods to the underlying hash
        def method_missing(method, *args, &block)
          if @hash.respond_to?(method)
            @hash.send(method, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(method, include_private = false)
          @hash.respond_to?(method, include_private) || super
        end

        # Liquid compatibility
        def to_liquid
          self
        end
      end

      # Trackable Array wrapper that records access
      class TrackableArray
        def initialize(array, path, recorder)
          @array = array
          @path = path
          @recorder = recorder
        end

        # Intercept [] access to record reads
        def [](index)
          value = @array[index]
          full_path = "#{@path}[#{index}]"
          
          # Record the access for arrays
          @recorder.emit_drop_read(self, index.to_s, value)
          
          # Wrap nested values for continued tracking
          @recorder.wrap_value_for_tracking(value, full_path)
        end

        # Support liquid iteration
        def each(&block)
          @array.each_with_index do |item, index|
            wrapped_item = self[index]  # This will record the access
            block.call(wrapped_item)
          end
        end

        # Forward other methods to the underlying array
        def method_missing(method, *args, &block)
          if @array.respond_to?(method)
            @array.send(method, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(method, include_private = false)
          @array.respond_to?(method, include_private) || super
        end

        # Liquid compatibility
        def to_liquid
          self
        end
      end

      private

      # Bind context variables to root paths
      #
      # @param context [Liquid::Context] Liquid context
      def bind_context_variables(context)
        return unless context.respond_to?(:scopes)
        
        # Bind variables from the current scope
        if context.scopes && !context.scopes.empty?
          scope = context.scopes.first
          scope.each do |key, value|
            if value.respond_to?(:invoke_drop)
              @binding_tracker.bind_root_object(value, key.to_s)
            end
          end
        end
        
        # Also check environments for additional bindings
        if context.respond_to?(:environments)
          context.environments.each do |env|
            env.each do |key, value|
              if value.respond_to?(:invoke_drop)
                @binding_tracker.bind_root_object(value, key.to_s)
              end
            end
          end
        end
      end

      # Resolve collection expression to a path
      #
      # @param collection_expr [String] Collection expression
      # @return [String] Resolved collection path
      def resolve_collection_path(collection_expr)
        # For simple variable references, return as-is
        # For more complex expressions, we'd need more sophisticated parsing
        # For now, handle the common case of simple variable access
        if collection_expr =~ /\A(\w+(?:\.\w+)*)\z/
          $1
        else
          collection_expr
        end
      end
    end
  end
end