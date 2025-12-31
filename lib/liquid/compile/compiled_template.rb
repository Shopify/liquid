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
    #   # Render with a Liquid::Context (preferred)
    #   context = Liquid::Context.new({ "name" => "World" })
    #   result = compiled.render(context)
    #   # => "Hello, World!"
    #
    #   # Or render with a simple hash
    #   result = compiled.render({ "name" => "World" })
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

      # Render the compiled template.
      #
      # @param context_or_assigns [Liquid::Context, Hash] A Liquid context or hash of assigns
      # @param registers [Hash] Registers (only used when passing a Hash)
      # @param filter_handler [Object] Optional filter handler module
      # @yield [call_type, *args] Called for external tags/filters only
      # @return [String] The rendered output
      #
      def render(context_or_assigns = {}, registers: {}, filter_handler: nil, &block)
        compiled_proc = to_proc
        handler = filter_handler || @filter_handler

        # Accept either a Liquid::Context or a Hash of assigns
        if context_or_assigns.is_a?(Liquid::Context)
          liquid_context = context_or_assigns
          assigns = extract_assigns(liquid_context)
          file_system = liquid_context.registers[:file_system]

          # Build external handler that handles include/render internally
          external_handler = build_external_handler(liquid_context, file_system, handler, &block)

          # Use a wrapper context that delegates to the Liquid::Context
          context = ContextWrapper.new(liquid_context)
        else
          assigns = context_or_assigns
          file_system = registers[:file_system]

          # Create a minimal context for Drop support
          context = CompiledContext.new(assigns, registers: registers)

          # Build external handler
          external_handler = build_external_handler(nil, file_system, handler, &block)
        end

        compiled_proc.call(assigns, context, external_handler)
      end

      alias call render

      def code
        @source
      end

      def to_s
        @source
      end

      def to_proc
        @proc ||= compile_to_proc
      end

      private

      def extract_assigns(liquid_context)
        # Get the first environment (static_environments)
        liquid_context.environments.first || {}
      end

      # Build the external call handler
      # Handles :include and :render internally using file_system
      # Yields to block for :tag and :filter if block given
      def build_external_handler(liquid_context, file_system, filter_handler, &block)
        external_tags = @external_tags

        ->(call_type, *args) do
          case call_type
          when :include
            handle_include(liquid_context, file_system, *args)

          when :render
            handle_render(liquid_context, file_system, *args)

          when :tag
            if block
              block.call(call_type, *args)
            else
              handle_tag(liquid_context, external_tags, *args)
            end

          when :filter
            if block
              block.call(call_type, *args)
            else
              handle_filter(liquid_context, filter_handler, *args)
            end

          else
            if block
              block.call(call_type, *args)
            else
              raise ArgumentError, "Unknown external call type: #{call_type}"
            end
          end
        end
      end

      def handle_include(liquid_context, file_system, template_name, variable, attrs, alias_name, assigns, context)
        raise Liquid::FileSystemError, "Could not find asset #{template_name}" unless file_system

        snippet_source = file_system.read_template_file(template_name)
        snippet = Liquid::Template.parse(snippet_source, line_numbers: true)
        snippet.name = template_name

        # Include shares scope with parent
        if liquid_context
          # Set attributes in context
          attrs&.each { |k, v| liquid_context[k] = v }

          context_var_name = alias_name || template_name.to_s.split('/').last
          if variable
            if variable.is_a?(Array)
              return variable.map do |item|
                liquid_context[context_var_name] = item
                snippet.render(liquid_context)
              end.join
            else
              liquid_context[context_var_name] = variable
            end
          end

          snippet.render(liquid_context)
        else
          # No liquid context - just use assigns
          render_assigns = assigns.merge(attrs || {})
          snippet.render(render_assigns)
        end
      end

      def handle_render(liquid_context, file_system, template_name, variable, attrs, alias_name, is_for_loop, context)
        raise Liquid::FileSystemError, "Could not find asset #{template_name}" unless file_system

        snippet_source = file_system.read_template_file(template_name)
        snippet = Liquid::Template.parse(snippet_source, line_numbers: true)
        snippet.name = template_name

        # Render creates isolated scope - only attrs are passed
        render_assigns = attrs&.dup || {}
        context_var_name = alias_name || template_name.to_s.split('/').last.sub(/\.liquid$/, '')

        if variable
          if is_for_loop && variable.is_a?(Array)
            return variable.map do |item|
              render_assigns[context_var_name] = item
              if liquid_context
                isolated_ctx = Liquid::Context.build(
                  static_environments: render_assigns,
                  registers: liquid_context.registers,
                  rethrow_errors: false,
                )
                isolated_ctx.exception_renderer = liquid_context.exception_renderer
                snippet.render(isolated_ctx)
              else
                snippet.render(render_assigns)
              end
            end.join
          else
            render_assigns[context_var_name] = variable
          end
        end

        if liquid_context
          isolated_ctx = Liquid::Context.build(
            static_environments: render_assigns,
            registers: liquid_context.registers,
            rethrow_errors: false,
          )
          isolated_ctx.exception_renderer = liquid_context.exception_renderer
          snippet.render(isolated_ctx)
        else
          snippet.render(render_assigns)
        end
      end

      def handle_tag(liquid_context, external_tags, tag_var, tag_assigns)
        tag = external_tags[tag_var]
        return '' unless tag

        if liquid_context
          output = +''
          tag.render_to_output_buffer(liquid_context, output)
          output
        else
          # Create a minimal context
          ctx = Liquid::Context.new([tag_assigns], {}, {}, false, nil, {}, Liquid::Environment.default)
          output = +''
          tag.render_to_output_buffer(ctx, output)
          output
        end
      end

      def handle_filter(liquid_context, filter_handler, filter_name, input, *filter_args)
        # Try filter handler first
        if filter_handler&.respond_to?(filter_name)
          return filter_handler.public_send(filter_name, input, *filter_args)
        end

        # Try liquid context's strainer
        if liquid_context
          strainer = liquid_context.strainer
          if strainer.class.invokable?(filter_name)
            return strainer.invoke(filter_name, input, *filter_args)
          end
        end

        # Return input unchanged if filter not found
        input
      end

      def compile_to_proc
        if Liquid::Box.secure?
          compile_in_sandbox
        else
          compile_insecure
        end
      end

      def compile_in_sandbox
        @box ||= begin
          box = Liquid::Box.new
          box.load_liquid_runtime!
          box.lock!
          box
        end

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

        ->(assigns, context, external_handler) do
          template_class.render(assigns, context, external_handler)
        end
      end

      def compile_insecure
        warn_once_insecure unless Liquid::Box.secure?

        require_relative 'runtime' unless defined?(::LR)

        # rubocop:disable Security/Eval
        eval(@source)
        # rubocop:enable Security/Eval
      end

      def warn_once_insecure
        return if @warned_insecure

        @warned_insecure = true
        warn "[SECURITY WARNING] Liquid compiled template running outside of Ruby::Box sandbox. " \
             "On Ruby 4.0+, this runs in a secure sandbox. On earlier versions, be cautious " \
             "about running untrusted templates."
      end

      # Wrapper around Liquid::Context for compiled template compatibility
      class ContextWrapper
        def initialize(liquid_context)
          @liquid_context = liquid_context
        end

        def [](key)
          @liquid_context[key]
        end

        def []=(key, value)
          @liquid_context[key] = value
        end

        def key?(key)
          @liquid_context.key?(key)
        end

        def registers
          @liquid_context.registers
        end

        def strainer
          @liquid_context.strainer
        end

        def handle_error(e, line_number = nil)
          @liquid_context.handle_error(e, line_number)
        end
      end
    end
  end
end
