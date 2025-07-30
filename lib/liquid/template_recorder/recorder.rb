# frozen_string_literal: true

module Liquid
  class TemplateRecorder
    class Recorder
      attr_reader :event_log, :binding_tracker

      def initialize
        @event_log = EventLog.new
        @binding_tracker = BindingTracker.new
        @template_info = {}
        @context_info = {}
        @last_output = nil
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

      # Record a filter call
      #
      # @param name [String, Symbol] Filter name
      # @param input [Object] Input value
      # @param args [Array] Filter arguments
      # @param output [Object] Filter output
      # @param location [Hash, nil] Location information
      def emit_filter_call(name, input, args, output, location = nil)
        @event_log.add_filter_call(
          name.to_s,
          input,
          args || [],
          output,
          location
        )
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
        assigns = @event_log.finalize_to_assigns_tree
        
        JsonSchema.build_recording_data(
          template_source: @template_info[:source] || "",
          assigns: assigns,
          file_reads: @event_log.file_reads,
          filter_calls: @event_log.filter_calls,
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