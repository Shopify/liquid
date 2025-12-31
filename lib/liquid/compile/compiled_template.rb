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
    # == External Calls (Tags and Filters)
    #
    # When the sandbox encounters an external tag or filter it can't handle,
    # it yields back to the caller. You can provide a block to handle these:
    #
    #   compiled.render(assigns) do |call_type, *args|
    #     case call_type
    #     when :tag
    #       tag_name, tag_obj, tag_context = args
    #       tag_obj.render(tag_context)
    #     when :filter
    #       filter_name, input, filter_args = args
    #       my_filter_handler.send(filter_name, input, *filter_args)
    #     end
    #   end
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
      # When the template needs to call an external tag or filter, it yields
      # back to the caller with [:tag, ...] or [:filter, ...] args. If no block
      # is given, a default handler is used.
      #
      # @param assigns [Hash] Variables to make available in the template
      # @param registers [Hash] Registers for custom tags (accessible via context.registers)
      # @param filter_handler [Object] Optional filter handler module
      # @param strict_variables [Boolean] Raise on undefined variables
      # @param strict_filters [Boolean] Raise on undefined filters
      # @yield [call_type, *args] Called for external tags/filters
      # @return [String] The rendered output
      #
      # @example Basic usage
      #   compiled.render({ "name" => "World" })
      #
      # @example With block for external calls
      #   compiled.render(assigns) do |type, *args|
      #     case type
      #     when :tag then handle_tag(*args)
      #     when :filter then handle_filter(*args)
      #     end
      #   end
      #
      def render(assigns = {}, registers: {}, filter_handler: nil, strict_variables: false, strict_filters: false, &block)
        compiled_proc = to_proc
        handler = filter_handler || @filter_handler

        # Create a context for Drop support
        context = CompiledContext.new(
          assigns,
          registers: registers,
          strict_variables: strict_variables,
          strict_filters: strict_filters
        )

        # Create the external call handler
        external_handler = block || default_external_handler(handler)

        # Build arguments: assigns, context, external_handler
        compiled_proc.call(assigns, context, external_handler)
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

      # Default handler for external calls when no block is provided
      def default_external_handler(filter_handler)
        external_tags = @external_tags

        ->(call_type, *args) do
          case call_type
          when :tag
            tag_var, tag_assigns = args
            tag = external_tags[tag_var]
            return '' unless tag

            # Create a context and render the tag
            ctx = Liquid::Context.new(
              [tag_assigns], {}, {},
              false, nil, {},
              Liquid::Environment.default
            )
            output = +''
            tag.render_to_output_buffer(ctx, output)
            output

          when :filter
            filter_name, input, filter_args = args
            if filter_handler&.respond_to?(filter_name)
              m = filter_handler.method(filter_name)
              m.call(input, *filter_args)
            else
              input  # Return unchanged if filter not found
            end

          else
            raise ArgumentError, "Unknown external call type: #{call_type}"
          end
        end
      end

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

            def self.render(*args, &block)
              TEMPLATE_PROC.call(*args, &block)
            end
          end
        RUBY

        @box.eval(class_code)
        template_class = @box[template_class_name]

        # Return a proc that delegates to the sandboxed class
        ->(assigns, context, external_handler) do
          template_class.render(assigns, context, external_handler)
        end
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
