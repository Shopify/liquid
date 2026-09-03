# frozen_string_literal: true

module Liquid
  # Templates are central to liquid.
  # Interpreting templates is a two step process. First you compile the
  # source code you got. During compile time some extensive error checking is performed.
  # your code should expect to get some SyntaxErrors.
  #
  # After you have a compiled template you can then <tt>render</tt> it.
  # You can use a compiled template over and over again and keep it cached.
  #
  # Example:
  #
  #   template = Liquid::Template.parse(source)
  #   template.render('user_name' => 'bob')
  #
  class Template
    attr_accessor :root, :name
    attr_reader :resource_limits, :warnings

    attr_reader :profiler

    class << self
      # Sets how strict the parser should be.
      # :lax acts like liquid 2.5 and silently ignores malformed tags in most cases.
      # :warn is the default and will give deprecation warnings when invalid syntax is used.
      # :strict enforces correct syntax for most tags
      # :strict2 enforces correct syntax for all tags
      def error_mode=(mode)
        Deprecations.warn("Template.error_mode=", "Environment#error_mode=")
        Environment.default.error_mode = mode
      end

      def error_mode
        Environment.default.error_mode
      end

      def default_exception_renderer=(renderer)
        Deprecations.warn("Template.default_exception_renderer=", "Environment#exception_renderer=")
        Environment.default.exception_renderer = renderer
      end

      def default_exception_renderer
        Environment.default.exception_renderer
      end

      def file_system=(file_system)
        Deprecations.warn("Template.file_system=", "Environment#file_system=")
        Environment.default.file_system = file_system
      end

      def file_system
        Environment.default.file_system
      end

      def tags
        Environment.default.tags
      end

      def register_tag(name, klass)
        Deprecations.warn("Template.register_tag", "Environment#register_tag")
        Environment.default.register_tag(name, klass)
      end

      # Pass a module with filter methods which should be available
      # to all liquid views. Good for registering the standard library
      def register_filter(mod)
        Deprecations.warn("Template.register_filter", "Environment#register_filter")
        Environment.default.register_filter(mod)
      end

      private def default_resource_limits=(limits)
        Deprecations.warn("Template.default_resource_limits=", "Environment#default_resource_limits=")
        Environment.default.default_resource_limits = limits
      end

      def default_resource_limits
        Environment.default.default_resource_limits
      end

      # creates a new <tt>Template</tt> object from liquid source code
      # To enable profiling, pass in <tt>profile: true</tt> as an option.
      # See Liquid::Profiler for more information
      def parse(source, options = {})
        environment = options[:environment] || Environment.default
        new(environment: environment).parse(source, options)
      end
    end

    def initialize(environment: Environment.default)
      @environment = environment
      @rethrow_errors  = false
      @resource_limits = ResourceLimits.new(environment.default_resource_limits)
    end

    # Parse source code.
    # Returns self for easy chaining
    def parse(source, options = {})
      parse_context = configure_options(options)
      source = source.to_s.to_str

      unless source.valid_encoding?
        raise TemplateEncodingError, parse_context.locale.t("errors.syntax.invalid_template_encoding")
      end

      tokenizer     = parse_context.new_tokenizer(source, start_line_number: @line_numbers && 1)
      @root         = Document.parse(tokenizer, parse_context)
      @template_recorder_source = source.dup.freeze if defined?(TemplateRecorder) && TemplateRecorder.current
      self
    end

    def registers
      @registers ||= {}
    end

    def assigns
      @assigns ||= {}
    end

    def instance_assigns
      @instance_assigns ||= {}
    end

    def errors
      @errors ||= []
    end

    # Render takes a hash with local variables.
    #
    # if you use the same filters over and over again consider registering them globally
    # with <tt>Template.register_filter</tt>
    #
    # if profiling was enabled in <tt>Template#parse</tt> then the resulting profiling information
    # will be available via <tt>Template#profiler</tt>
    #
    # Following options can be passed:
    #
    #  * <tt>filters</tt> : array with local filters
    #  * <tt>registers</tt> : hash with register variables. Those can be accessed from
    #    filters and tags and might be useful to integrate liquid more with its host application
    #
    def render(*args)
      return '' if @root.nil?

      recording_session = TemplateRecorder.current if defined?(TemplateRecorder)
      recording_assigns = args.first
      context = case args.first
      when Liquid::Context
        c = args.shift

        if @rethrow_errors
          c.exception_renderer = Liquid::RAISE_EXCEPTION_LAMBDA
        end

        c
      when Liquid::Drop
        drop = args.shift
        c    = Context.new([drop, assigns], instance_assigns, registers, @rethrow_errors, @resource_limits, {}, @environment)
        drop.context = c if drop.respond_to?(:context=)
        c
      when Hash
        Context.new([args.shift, assigns], instance_assigns, registers, @rethrow_errors, @resource_limits, {}, @environment)
      when nil
        Context.new(assigns, instance_assigns, registers, @rethrow_errors, @resource_limits, {}, @environment)
      else
        raise ArgumentError, "Expected Hash or Liquid::Context as parameter"
      end

      output = nil

      case args.last
      when Hash
        options = args.pop
        output  = options[:output] if options[:output]
        static_registers = context.registers.static

        options[:registers]&.each do |key, register|
          static_registers[key] = register
        end

        apply_options_to_context(context, options)
      when Module, Array
        context.add_filters(args.pop)
      end

      recording = recording_session&.begin_render(self, recording_assigns, context)
      if recording
        recorder_registers = context.registers.static
        previous_recorder = recorder_registers[TemplateRecorder::REGISTER_KEY]
        recorder_registers[TemplateRecorder::REGISTER_KEY] = recording
      end

      # Retrying a render resets resource usage
      context.resource_limits.reset

      if @profiling && context.profiler.nil?
        @profiler = context.profiler = Liquid::Profiler.new
      end

      context.template_name ||= name

      previous_error_mode = context.registers.static[:template_error_mode]
      context.registers.static[:template_error_mode] = @error_mode

      rendered_output = nil
      render_succeeded = false
      # A caller may hand in a buffer that already holds bytes this template did
      # not produce, and may keep appending to it after this render returns. The
      # recording must describe only what the template rendered, so remember
      # where its output starts.
      recorded_output_start = recording ? (output || '').bytesize : 0
      begin
        # render the nodelist.
        rendered_output = @root.render_to_output_buffer(context, output || +'')
        render_succeeded = true
        rendered_output
      rescue Liquid::MemoryError => e
        rendered_output = context.handle_error(e)
        # The caller still gets the error text, but a render that hit the memory
        # limit is truncated by definition: recording it as a success would put
        # a partial render into the corpus as if it were the specified output.
        render_succeeded = false
        recorded_output_start = 0
        rendered_output
      ensure
        if previous_error_mode
          context.registers.static[:template_error_mode] = previous_error_mode
        else
          context.registers.static.delete(:template_error_mode)
        end
        if recording
          if previous_recorder
            recorder_registers[TemplateRecorder::REGISTER_KEY] = previous_recorder
          else
            recorder_registers.delete(TemplateRecorder::REGISTER_KEY)
          end
          # Slice off any caller-supplied prefix, and copy: the buffer is the
          # caller's and may still be appended to, which would otherwise leak
          # bytes into a recording that has already been taken.
          recorded_output = if rendered_output.is_a?(String)
            rendered_output.byteslice(recorded_output_start, rendered_output.bytesize - recorded_output_start).dup
          else
            rendered_output
          end
          recording_session.finish_render(recording, recorded_output, context, success: render_succeeded)
        end
        @errors = context.errors
      end
    end

    def render!(*args)
      @rethrow_errors = true
      render(*args)
    end

    def render_to_output_buffer(context, output)
      render(context, output: output)
    end

    private

    def configure_options(options)
      if (profiling = options[:profile])
        raise "Profiler not loaded, require 'liquid/profiler' first" unless defined?(Liquid::Profiler)
      end

      @options      = options
      @profiling    = profiling
      @line_numbers = options[:line_numbers] || @profiling
      parse_context = if options.is_a?(ParseContext)
        options
      else
        opts = options.key?(:environment) ? options : options.merge(environment: @environment)
        ParseContext.new(opts)
      end

      @warnings = parse_context.warnings
      @error_mode = parse_context.error_mode
      parse_context
    end

    def apply_options_to_context(context, options)
      context.add_filters(options[:filters]) if options[:filters]
      context.global_filter      = options[:global_filter] if options[:global_filter]
      context.exception_renderer = options[:exception_renderer] if options[:exception_renderer]
      context.strict_variables   = options[:strict_variables] if options[:strict_variables]
      context.strict_filters     = options[:strict_filters] if options[:strict_filters]
    end
  end
end
