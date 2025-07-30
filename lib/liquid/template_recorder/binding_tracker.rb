# frozen_string_literal: true

module Liquid
  class TemplateRecorder
    class BindingTracker
      def initialize
        @object_bindings = {}  # object_id => variable_path
        @loop_stack = []       # current loop context stack
      end

      # Bind a root-level object to a variable path
      #
      # @param object [Object] The object to bind
      # @param path [String] Variable path (e.g., "product")
      def bind_root_object(object, path)
        return unless object
        @object_bindings[object.object_id] = path
      end

      # Bind a loop item object to its array position path
      #
      # @param object [Object] The loop item object
      # @param path [String] Full path including array index (e.g., "product.variants[1]")
      def bind_loop_item(object, path)
        return unless object
        @object_bindings[object.object_id] = path
      end

      # Resolve the binding path for an object
      #
      # @param object [Object] Object to resolve path for
      # @return [String, nil] Variable path or nil if not bound
      def resolve_binding_path(object)
        return nil unless object
        @object_bindings[object.object_id]
      end

      # Enter a new loop context
      #
      # @param collection_path [String] Path to the collection being iterated
      # @param variable_name [String] Name of the loop variable (e.g., "category", "item")
      def enter_loop(collection_path, variable_name = nil)
        parent_context = @loop_stack.last
        
        @loop_stack.push({
          collection_path: collection_path,
          variable_name: variable_name,
          parent_path: parent_context&.[](:current_item_path),
          current_index: nil,
          current_item_path: nil,
          items: []
        })
      end

      # Bind an item in the current loop
      #
      # @param index [Integer] Array index of the item
      # @param item [Object] The item object
      def bind_current_loop_item(index, item)
        return if @loop_stack.empty?
        
        current_loop = @loop_stack.last
        item_path = "#{current_loop[:collection_path]}[#{index}]"
        
        # Update current context
        current_loop[:current_index] = index
        current_loop[:current_item_path] = item_path
        
        # Always bind the full path for direct resolution
        bind_loop_item(item, item_path)
        
        # For templates with loop variables, also bind the variable name for property resolution
        # This allows find_loop_variable_path to work correctly
        if current_loop[:variable_name] && item
          # Store the variable name mapping for hierarchical path resolution
          @object_bindings["#{item.object_id}_var"] = current_loop[:variable_name]
        end
        
        # Track this as a loop item path 
        current_loop[:items][index] = item_path
      end

      # Exit the current loop context
      #
      # @return [Hash, nil] Loop context that was exited
      def exit_loop
        @loop_stack.pop
      end

      # Get the current loop depth
      #
      # @return [Integer] Number of nested loops
      def loop_depth
        @loop_stack.length
      end

      # Check if currently inside a loop
      #
      # @return [Boolean] True if inside a loop
      def in_loop?
        !@loop_stack.empty?
      end

      # Get the current loop context
      #
      # @return [Hash, nil] Current loop context or nil
      def current_loop
        @loop_stack.last
      end

      # Build property access path for an object and method
      #
      # @param object [Object] Object being accessed
      # @param method_name [String] Method/property name
      # @return [String, nil] Full property path or nil if object not bound
      def build_property_path(object, method_name)
        # Check if this object is a loop variable first
        if loop_variable_path = find_loop_variable_path(object)
          return "#{loop_variable_path}.#{method_name}"
        end
        
        # Fall back to normal binding resolution
        base_path = resolve_binding_path(object)
        return nil unless base_path
        
        "#{base_path}.#{method_name}"
      end

      # Clear all bindings (for testing)
      def clear!
        @object_bindings.clear
        @loop_stack.clear
      end

      # Get all current bindings (for debugging)
      #
      # @return [Hash] Copy of current object bindings
      def current_bindings
        @object_bindings.dup
      end

      private

      # Find the hierarchical path for a loop variable
      #
      # @param object [Object] Object to find path for
      # @return [String, nil] Hierarchical path like "categories[0]" or nil
      def find_loop_variable_path(object)
        return nil unless object
        
        object_binding = @object_bindings[object.object_id]
        
        # Look through loop stack from most recent to oldest
        @loop_stack.reverse_each do |loop_context|
          # Check if this object is bound to the current loop variable name
          if loop_context[:variable_name] && 
             object_binding == loop_context[:variable_name] &&
             loop_context[:current_item_path]
            return loop_context[:current_item_path]
          end
        end
        
        nil
      end
    end
  end
end