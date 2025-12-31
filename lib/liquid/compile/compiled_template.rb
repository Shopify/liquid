# frozen_string_literal: true

module Liquid
  module Compile
    # CompiledTemplate represents a compiled Liquid template ready for secure execution.
    #
    # This class wraps generated Ruby code and provides a secure execution environment
    # using Liquid::Box. On Ruby 4.0+, execution happens in a true sandbox. On earlier
    # versions, a polyfill is used with a security warning.
    #
    # == Usage
    #
    #   template = Liquid::Template.parse("Hello, {{ name }}!")
    #   compiled = template.compile_to_ruby
    #
    #   # Render the template
    #   result = compiled.render({ "name" => "World" })
    #   # => "Hello, World!"
    #
    #   # Access the source code
    #   puts compiled.source
    #
    #   # Check security status
    #   compiled.secure?  # => true on Ruby 4.0+, false otherwise
    #
    class CompiledTemplate
      attr_reader :source, :external_tags
      attr_accessor :filter_handler

      # @param source [String] The generated Ruby code
      # @param external_tags [Hash] Map of variable names to Tag objects for runtime delegation
      # @param has_external_filters [Boolean] Whether external filters are used
      def initialize(source, external_tags = {}, has_external_filters = false)
        @source = source
        @external_tags = external_tags
        @has_external_filters = has_external_filters
        @filter_handler = nil
        @proc = nil
        @box = nil
      end

      # Returns true if this template has external tags that need runtime delegation
      def has_external_tags?
        !@external_tags.empty?
      end

      # Returns true if this template uses external filters
      def has_external_filters?
        @has_external_filters
      end

      # Returns true if execution will be sandboxed (Ruby 4.0+)
      def secure?
        Liquid::Box.secure?
      end

      # Render the compiled template with the given assigns.
      #
      # This is the primary way to execute a compiled template. On Ruby 4.0+,
      # execution happens in a secure sandbox. On earlier versions, a warning
      # is printed to STDERR.
      #
      # @param assigns [Hash] Variables to make available in the template
      # @param registers [Hash] Registers for custom tags (accessible via context.registers)
      # @param filter_handler [Object] Optional filter handler module
      # @param strict_variables [Boolean] Raise on undefined variables
      # @param strict_filters [Boolean] Raise on undefined filters
      # @return [String] The rendered output
      #
      # @example Basic usage
      #   compiled.render({ "name" => "World" })
      #
      # @example With registers
      #   compiled.render({ "product" => product }, registers: { shop: current_shop })
      #
      def render(assigns = {}, registers: {}, filter_handler: nil, strict_variables: false, strict_filters: false)
        proc = to_proc
        handler = filter_handler || @filter_handler

        # Create a context for Drop support
        context = CompiledContext.new(
          assigns,
          registers: registers,
          strict_variables: strict_variables,
          strict_filters: strict_filters
        )

        # Build arguments based on what the lambda expects
        args = [assigns]
        args << @external_tags if has_external_tags?
        args << handler if has_external_filters?
        args << context  # Always pass context as last arg

        proc.call(*args)
      end

      # Alias for backwards compatibility
      alias call render

      # Returns the generated Ruby source code
      def code
        @source
      end

      # Returns the Ruby code as a string
      def to_s
        @source
      end

      # Returns the compiled proc.
      #
      # On Ruby 4.0+, this compiles the code in a secure sandbox.
      # On earlier versions, this uses standard eval with a security warning.
      #
      # The proc is cached after first compilation.
      def to_proc
        @proc ||= compile_to_proc
      end

      private

      def compile_to_proc
        if Liquid::Box.secure?
          compile_in_sandbox
        else
          compile_insecure
        end
      end

      # Compile in a secure Ruby::Box sandbox (Ruby 4.0+)
      def compile_in_sandbox
        @box ||= begin
          box = Liquid::Box.new
          box.load_liquid_runtime!
          box.lock!
          box
        end

        # Wrap the lambda source in a class for the sandbox
        template_class_name = "CompiledTemplate_#{object_id}"
        class_code = <<~RUBY
          class #{template_class_name}
            TEMPLATE_PROC = #{@source}

            def self.render(*args)
              TEMPLATE_PROC.call(*args)
            end
          end
        RUBY

        @box.eval(class_code)
        template_class = @box[template_class_name]

        # Return a proc that delegates to the sandboxed class
        ->(assigns, *rest) { template_class.render(assigns, *rest) }
      end

      # Compile without sandbox (Ruby < 4.0) - shows warning
      def compile_insecure
        unless Liquid::Box.secure?
          warn_once_insecure
        end

        # rubocop:disable Security/Eval
        eval(@source)
        # rubocop:enable Security/Eval
      end

      def warn_once_insecure
        return if @warned_insecure
        @warned_insecure = true

        $stderr.puts <<~WARNING
          [Liquid::CompiledTemplate] WARNING: Executing compiled template WITHOUT sandbox.
          Ruby::Box requires Ruby 4.0+. Template execution is NOT SECURE on this Ruby version.
        WARNING
      end
    end
  end

  # Make CompiledTemplate available at the top level for convenience
  CompiledTemplate = Compile::CompiledTemplate
end
