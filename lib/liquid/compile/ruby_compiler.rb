# frozen_string_literal: true

module Liquid
  module Compile
    # RubyCompiler transforms a parsed Liquid template into pure Ruby code.
    #
    # The compiled code is a string that can be eval'd to create a proc/lambda
    # that takes an assigns hash and returns the rendered output string.
    #
    # ## Optimization Opportunities
    #
    # The compiled Ruby code has several significant advantages over interpreted Liquid:
    #
    # 1. **No Context Object**: Instead of using a Context for variable lookups,
    #    variables are extracted directly from the assigns hash and stored in
    #    local Ruby variables. This eliminates hash lookups on every access.
    #
    # 2. **No Filter Invocation Overhead**: Filters are compiled to direct Ruby
    #    method calls rather than going through context.invoke().
    #
    # 3. **No Resource Limits Tracking**: The compiled code doesn't track render
    #    scores, write scores, or assign scores, eliminating per-node overhead.
    #
    # 4. **No Stack-based Scoping**: Ruby's native block scoping is used instead
    #    of manually managing scope stacks with push/pop operations.
    #
    # 5. **Direct String Concatenation**: Output is built with direct << operations
    #    rather than through render_to_output_buffer abstractions.
    #
    # 6. **Native Control Flow**: break/continue become Ruby's break/next,
    #    eliminating interrupt objects and checks.
    #
    # 7. **No to_liquid Calls**: Values are used directly without conversion.
    #
    # 8. **Potential for Constant Folding**: Expressions with only literals
    #    could be evaluated at compile time (future enhancement).
    #
    # 9. **Potential for Dead Code Elimination**: Unreachable branches like
    #    `{% if false %}` could be removed (future enhancement).
    #
    # 10. **No Profiling Hooks**: No profiler overhead in the generated code.
    #
    # 11. **No Exception Rendering**: Errors propagate naturally rather than
    #     being caught and rendered inline.
    #
    # ## Usage
    #
    #   template = Liquid::Template.parse("Hello, {{ name }}!")
    #   ruby_code = template.compile_to_ruby
    #   render_proc = eval(ruby_code)
    #   result = render_proc.call({ "name" => "World" })
    #   # => "Hello, World!"
    #
    class RubyCompiler
      attr_reader :template, :options

      # @param template [Liquid::Template] The parsed template to compile
      # @param options [Hash] Compilation options
      # @option options [Boolean] :strict_variables Raise on undefined variables (default: false)
      # @option options [Boolean] :include_filters Include filter helper methods (default: true)
      # @option options [Boolean] :debug Emit source comments for debugging (default: false)
      # @option options [Object] :file_system File system for loading partials (default: template's environment)
      def initialize(template, options = {})
        @template = template
        @options = {
          strict_variables: false,
          include_filters: true,
          debug: false,
          file_system: nil,
        }.merge(options)
        @var_counter = 0
        @partials = {}        # Registered partials: name => method_name
        @partial_sources = {} # Partial sources: name => source code
        @partial_counter = 0
        @external_tags = {}   # External tags: var_name => tag object
        @external_tag_counter = 0
        @has_external_filters = false  # Whether we need the filter helper
      end

      # Mark that we have external filters
      def register_external_filter
        @has_external_filters = true
      end

      # Check if external filters are used
      def has_external_filters?
        @has_external_filters
      end

      # Register an external tag that will be called at runtime
      # @param tag [Liquid::Tag] The tag to register
      # @return [String] The variable name for this tag
      def register_external_tag(tag)
        @external_tag_counter += 1
        var_name = "__ext_tag_#{@external_tag_counter}__"
        @external_tags[var_name] = tag
        var_name
      end

      # Get all registered external tags
      # @return [Hash] Map of variable names to tag objects
      def external_tags
        @external_tags
      end

      # Get the file system for loading partials
      def file_system
        @options[:file_system] || @template.instance_variable_get(:@environment)&.file_system
      end

      # Load a partial source from the file system
      # @param name [String] The partial name
      # @return [String, nil] The partial source or nil if not found
      def load_partial(name)
        return @partial_sources[name] if @partial_sources.key?(name)

        fs = file_system
        return nil unless fs && fs.respond_to?(:read_template_file)

        begin
          source = fs.read_template_file(name)
          @partial_sources[name] = source
          source
        rescue Liquid::FileSystemError
          nil
        end
      end

      # Register a partial and return its method name
      # @param name [String] The partial name
      # @param source [String] The partial source
      # @return [String] The method name for this partial
      def register_partial(name, source)
        return @partials[name] if @partials.key?(name)

        @partial_counter += 1
        method_name = "__partial_#{@partial_counter}__"
        @partials[name] = method_name
        method_name
      end

      # Get all registered partials
      def registered_partials
        @partials
      end

      # Check if debug mode is enabled
      def debug?
        @options[:debug]
      end

      # Emit a debug comment with source location info
      # This creates a lightweight source map that allows tracing errors
      # back to the original Liquid source
      def emit_debug_comment(code, node, description = nil)
        return unless debug?

        line_number = node.respond_to?(:line_number) ? node.line_number : nil
        raw_markup = extract_raw_markup(node)

        comment_parts = []
        comment_parts << "LIQUID"
        comment_parts << "L#{line_number}" if line_number
        comment_parts << description if description
        comment_parts << raw_markup.inspect if raw_markup && raw_markup.length < 80

        code.line "# #{comment_parts.join(' | ')}"
      end

      # Extract the raw markup from a node for debug output
      def extract_raw_markup(node)
        case node
        when Variable
          "{{ #{node.raw} }}"
        when Tag
          if node.respond_to?(:raw)
            "{% #{node.tag_name} #{node.raw} %}"
          elsif node.respond_to?(:markup)
            "{% #{node.tag_name} #{node.markup} %}"
          else
            "{% #{node.class.name.split('::').last.downcase} %}"
          end
        else
          nil
        end
      end

      # Compile the template to a Ruby code string
      # @return [String] Ruby code that can be eval'd to create a render proc
      # @return [Hash] If external tags are used, returns { code: String, external_tags: Hash }
      def compile
        code = CodeGenerator.new

        # Add debug header if enabled
        if debug?
          code.line "# Compiled from Liquid template: #{@template.name || '(unnamed)'}"
          code.line "# Debug mode enabled - comments contain source locations"
          code.line "# Format: # LIQUID | L<line> | <description> | <source>"
          code.blank_line
        end

        # First pass: compile the document body to discover partials and external tags
        main_code = CodeGenerator.new
        compile_node(@template.root, main_code)

        # Determine lambda parameters based on external dependencies
        params = ["assigns = {}"]
        params << "__external_tags__ = {}" unless @external_tags.empty?
        params << "__filter_handler__ = nil" if @has_external_filters

        code.line "->(#{params.join(', ')}) do"

        code.indent do
          # Initialize the output buffer
          code.line '__output__ = +""'
          code.blank_line

          # Compile helper methods if needed
          if @options[:include_filters]
            compile_helper_methods(code)
            code.blank_line
          end

          # Add external tag runtime helper if needed
          unless @external_tags.empty?
            compile_external_tag_helper(code)
            code.blank_line
          end

          # Add external filter helper if needed
          if @has_external_filters
            compile_filter_helper(code)
            code.blank_line
          end

          # Compile partial methods (before main body so they're available)
          compile_partials(code)

          # Add the main body code
          code.raw(main_code.to_s)

          code.blank_line
          code.line "__output__"
        end
        code.line "end"

        code.to_s
      end

      # Compile helper for calling external tags at runtime
      def compile_external_tag_helper(code)
        code.line "# Helper for calling external (unknown) tags at runtime"
        code.line "__call_external_tag__ = ->(tag_var, tag_assigns) {"
        code.indent do
          code.line "tag = __external_tags__[tag_var]"
          code.line "next '' unless tag"
          code.line "# Create a context using the default environment (which has filters registered)"
          code.line "ctx = Liquid::Context.new([tag_assigns], {}, {}, false, nil, {}, Liquid::Environment.default)"
          code.line "output = +''"
          code.line "# Use render_to_output_buffer to ensure block tags work correctly"
          code.line "tag.render_to_output_buffer(ctx, output)"
          code.line "output"
        end
        code.line "}"
      end

      # Compile helper for calling external filters at runtime
      def compile_filter_helper(code)
        code.line "# Helper for calling external (unknown) filters at runtime"
        code.line "__call_filter__ = ->(name, input, args) {"
        code.indent do
          code.line "if __filter_handler__&.respond_to?(name)"
          code.indent do
            code.line "__filter_handler__.send(name, input, *args)"
          end
          code.line "else"
          code.indent do
            code.line "input # Return input unchanged if filter not found"
          end
          code.line "end"
        end
        code.line "}"
      end

      # Compile all registered partials as inner methods
      def compile_partials(code)
        @partials.each do |name, method_name|
          source = @partial_sources[name]
          next unless source

          code.line "# Partial: #{name}"
          code.line "#{method_name} = ->(partial_assigns) do"
          code.indent do
            code.line "__partial_output__ = +''"
            code.line "# Merge partial assigns with parent assigns"
            code.line "__assigns_backup__ = assigns.dup"
            code.line "assigns.merge!(partial_assigns)"
            code.blank_line

            # Parse and compile the partial
            # Note: We need to handle this carefully to avoid circular references
            begin
              compile_partial_source(source, code)
            rescue => e
              code.line "# Error compiling partial: #{e.message.inspect}"
              code.line "__partial_output__ << '[PARTIAL ERROR: #{name}]'"
            end

            code.blank_line
            code.line "# Restore assigns"
            code.line "assigns.replace(__assigns_backup__)"
            code.line "__partial_output__"
          end
          code.line "end"
          code.blank_line
        end
      end

      # Compile a partial source string
      def compile_partial_source(source, code)
        # Parse the partial source using the same environment
        environment = @template.instance_variable_get(:@environment) || Liquid::Environment.default
        parse_context = Liquid::ParseContext.new(environment: environment)
        tokenizer = parse_context.new_tokenizer(source)
        document = Liquid::Document.parse(tokenizer, parse_context)

        # Compile the partial's body, but swap output variable
        code.line "__saved_output__ = __output__"
        code.line "__output__ = __partial_output__"

        # Compile the document
        BlockBodyCompiler.compile(document.body, self, code)

        code.line "__output__ = __saved_output__"
      end

      # Generate a unique variable name for internal use
      def generate_var_name(prefix = "v")
        @var_counter += 1
        "__#{prefix}#{@var_counter}__"
      end

      # Compile a single node
      def compile_node(node, code)
        case node
        when Document
          BlockBodyCompiler.compile(node.body, self, code)
        when BlockBody
          BlockBodyCompiler.compile(node, self, code)
        when String
          compile_string(node, code)
        when Variable
          emit_debug_comment(code, node, "variable")
          VariableCompiler.compile(node, self, code)
        when Tag
          emit_debug_comment(code, node, node.class.name.split('::').last.downcase)
          compile_tag(node, code)
        else
          raise CompileError, "Unknown node type: #{node.class}"
        end
      end

      private

      def compile_string(str, code)
        return if str.empty?
        if debug? && str.length < 40
          code.line "# LIQUID | text | #{str.inspect}"
        end
        code.line "__output__ << #{str.inspect}"
      end

      def compile_tag(tag, code)
        compiler_class = find_tag_compiler(tag)
        if compiler_class
          compiler_class.compile(tag, self, code)
        else
          # Unknown tag - delegate to the original tag's render method at runtime
          compile_external_tag(tag, code)
        end
      end

      def compile_external_tag(tag, code)
        tag_var = register_external_tag(tag)
        tag_name = tag.class.name.split('::').last
        if debug?
          code.line "# External tag: #{tag_name} (delegated to runtime)"
          code.line "$stderr.puts '* WARN: Liquid external tag call - #{tag_name} (not compiled, delegated to runtime)' if $VERBOSE"
        end
        code.line "__output__ << __call_external_tag__.call(#{tag_var.inspect}, assigns)"
      end

      def find_tag_compiler(tag)
        case tag
        when Liquid::Unless  # Check Unless before If since Unless < If
          Tags::UnlessCompiler
        when Liquid::If
          Tags::IfCompiler
        when Liquid::Case
          Tags::CaseCompiler
        when Liquid::For
          Tags::ForCompiler
        when Liquid::Assign
          Tags::AssignCompiler
        when Liquid::Capture
          Tags::CaptureCompiler
        when Liquid::Cycle
          Tags::CycleCompiler
        when Liquid::Increment
          Tags::IncrementCompiler
        when Liquid::Decrement
          Tags::DecrementCompiler
        when Liquid::Raw
          Tags::RawCompiler
        when Liquid::Echo
          Tags::EchoCompiler
        when Liquid::Break
          Tags::BreakCompiler
        when Liquid::Continue
          Tags::ContinueCompiler
        when Liquid::Comment, Liquid::InlineComment, Liquid::Doc
          Tags::CommentCompiler
        when Liquid::TableRow
          Tags::TableRowCompiler
        when Liquid::Render
          Tags::RenderCompiler
        when Liquid::Include
          Tags::IncludeCompiler
        when Liquid::Ifchanged
          Tags::IfchangedCompiler
        else
          nil
        end
      end

      def compile_helper_methods(code)
        code.line "# Helper methods for filters and utilities"

        # to_s helper that handles arrays and hashes like Liquid does
        code.line "def __to_s__(obj)"
        code.indent do
          code.line "case obj"
          code.line "when NilClass then ''"
          code.line "when Array then obj.join"
          code.line "else obj.to_s"
          code.line "end"
        end
        code.line "end"
        code.blank_line

        # to_number helper
        code.line "def __to_number__(obj)"
        code.indent do
          code.line "case obj"
          code.line "when Numeric then obj"
          code.line "when String"
          code.indent do
            code.line "obj.strip =~ /\\A-?\\d+\\.\\d+\\z/ ? BigDecimal(obj) : obj.to_i"
          end
          code.line "else 0"
          code.line "end"
        end
        code.line "end"
        code.blank_line

        # to_integer helper
        code.line "def __to_integer__(obj)"
        code.indent do
          code.line "return obj if obj.is_a?(Integer)"
          code.line "Integer(obj.to_s)"
        end
        code.line "end"
        code.blank_line

        # Liquid truthiness helper
        code.line "def __truthy__(obj)"
        code.indent do
          code.line "obj != nil && obj != false"
        end
        code.line "end"
        code.blank_line

        # Variable lookup helper
        code.line "def __lookup__(obj, key)"
        code.indent do
          code.line "return nil if obj.nil?"
          code.line "if obj.respond_to?(:[]) && (obj.respond_to?(:key?) && obj.key?(key) || obj.respond_to?(:fetch) && key.is_a?(Integer))"
          code.indent do
            code.line "obj[key]"
          end
          code.line "elsif obj.respond_to?(key)"
          code.indent do
            code.line "obj.send(key)"
          end
          code.line "else"
          code.indent do
            code.line "nil"
          end
          code.line "end"
        end
        code.line "end"
        code.blank_line

        # Output helper that handles nil and arrays
        code.line "def __output_value__(obj)"
        code.indent do
          code.line "case obj"
          code.line "when NilClass then ''"
          code.line "when Array then obj.map { |o| __output_value__(o) }.join"
          code.line "else obj.to_s"
          code.line "end"
        end
        code.line "end"
      end
    end

    # Custom error for compilation issues
    class CompileError < StandardError; end
  end
end
