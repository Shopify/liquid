# frozen_string_literal: true

module Liquid
  module Compile
    # Represents a compiled Liquid template ready for execution.
    #
    # Contains the Ruby source code and any external tags/filters that need to be
    # passed to the generated lambda at runtime.
    #
    # Usage:
    #   compiled = template.compile_to_ruby
    #   result = compiled.call({ "name" => "World" })
    #
    #   # With custom filters:
    #   compiled.filter_handler = MyFilterModule
    #   result = compiled.call({ "name" => "World" })
    #
    class CompiledTemplate
      attr_reader :code, :external_tags
      attr_accessor :filter_handler

      # @param code [String] The generated Ruby code
      # @param external_tags [Hash] Map of variable names to Tag objects for runtime delegation
      # @param has_external_filters [Boolean] Whether external filters are used
      def initialize(code, external_tags = {}, has_external_filters = false)
        @code = code
        @external_tags = external_tags
        @has_external_filters = has_external_filters
        @filter_handler = nil
        @proc = nil
      end

      # Returns true if this template has external tags that need runtime delegation
      def has_external_tags?
        !@external_tags.empty?
      end

      # Returns true if this template uses external filters
      def has_external_filters?
        @has_external_filters
      end

      # Returns the compiled proc, caching it after first compilation
      def to_proc
        @proc ||= eval(@code)
      end

      # Execute the compiled template with the given assigns
      # @param assigns [Hash] The variable assignments
      # @param filter_handler [Object] Optional filter handler to override the default
      # @return [String] The rendered output
      def call(assigns = {}, filter_handler: nil)
        proc = to_proc
        handler = filter_handler || @filter_handler

        # Build arguments based on what the lambda expects
        args = [assigns]
        args << @external_tags if has_external_tags?
        args << handler if has_external_filters?

        proc.call(*args)
      end

      # Returns the Ruby code as a string
      def to_s
        @code
      end
    end
  end

  # Make CompiledTemplate available at the top level for convenience
  CompiledTemplate = Compile::CompiledTemplate
end
