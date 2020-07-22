# frozen_string_literal: true

module Liquid
  # Templates are central to liquid.
  # Interpretating templates is a two step process. First you compile the
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
    attr_accessor :root
    attr_reader :warnings

    class TagRegistry
      include Enumerable

      def initialize
        @tags  = {}
        @cache = {}
      end

      def [](tag_name)
        return nil unless @tags.key?(tag_name)
        return @cache[tag_name] if Liquid.cache_classes

        lookup_class(@tags[tag_name]).tap { |o| @cache[tag_name] = o }
      end

      def []=(tag_name, klass)
        @tags[tag_name]  = klass.name
        @cache[tag_name] = klass
      end

      def delete(tag_name)
        @tags.delete(tag_name)
        @cache.delete(tag_name)
      end

      def each(&block)
        @tags.each(&block)
      end

      private

      def lookup_class(name)
        Object.const_get(name)
      end
    end

    attr_reader :profiler

    class << self
      # Sets how strict the parser should be.
      # :lax acts like liquid 2.5 and silently ignores malformed tags in most cases.
      # :warn is the default and will give deprecation warnings when invalid syntax is used.
      # :strict will enforce correct syntax.
      attr_accessor :error_mode
      Template.error_mode = :lax

      attr_accessor :default_exception_renderer
      Template.default_exception_renderer = lambda do |exception|
        exception
      end

      attr_accessor :file_system
      Template.file_system = BlankFileSystem.new

      attr_accessor :tags
      Template.tags = TagRegistry.new
      private :tags=

      def register_tag(name, klass)
        tags[name.to_s] = klass
      end

      attr_accessor :registers
      Template.registers = {}
      private :registers=

      def add_register(name, klass)
        registers[name.to_sym] = klass
      end

      # Pass a module with filter methods which should be available
      # to all liquid views. Good for registering the standard library
      def register_filter(mod)
        StrainerFactory.add_global_filter(mod)
      end

      attr_accessor :default_resource_limits
      Template.default_resource_limits = {}
      private :default_resource_limits=

      # creates a new <tt>Template</tt> object from liquid source code
      # To enable profiling, pass in <tt>profile: true</tt> as an option.
      # See Liquid::Profiler for more information
      def parse(source, options = {})
        new.parse(source, options)
      end
    end

    # Parse source code.
    # Returns self for easy chaining
    def parse(source, options = {})
      @options      = options
      @profiling    = options[:profile]
      @line_numbers = options[:line_numbers] || @profiling
      parse_context = options.is_a?(ParseContext) ? options : ParseContext.new(options)
      @root         = Document.parse(tokenize(source), parse_context)
      @warnings     = parse_context.warnings
      self
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
    def render(assigns_or_context = nil, options = nil)
      return '' if @root.nil?

      context = coerce_context(assigns_or_context)

      output = nil

      context_register = context.registers.is_a?(StaticRegisters) ? context.registers.static : context.registers

      case options
      when Hash
        output = options[:output] if options[:output]

        options[:registers]&.each do |key, register|
          context_register[key] = register
        end

        apply_options_to_context(context, options)
      when Module, Array
        context.add_filters(options)
      end

      Template.registers.each do |key, register|
        context_register[key] = register unless context_register.key?(key)
      end

      # Retrying a render resets resource usage
      context.resource_limits.reset

      begin
        # render the nodelist.
        # for performance reasons we get an array back here. join will make a string out of it.
        with_profiling(context) do
          @root.render_to_output_buffer(context, output || +'')
        end
      rescue Liquid::MemoryError => e
        context.handle_error(e)
      end
    end

    def render!(assigns_or_context = nil, options = nil)
      context = coerce_context(assigns_or_context)
      # rethrow errors
      context.exception_renderer = ->(_e) { raise }

      render(context, options)
    end

    def render_to_output_buffer(context, output)
      render(context, output: output)
    end

    private

    def coerce_context(assigns_or_context)
      case assigns_or_context
      when Liquid::Context
        assigns_or_context
      when Liquid::Drop
        drop = assigns_or_context
        drop.context = Context.build(environments: [drop])
      when Hash
        Context.build(environments: [assigns_or_context])
      when nil
        Context.build
      else
        raise ArgumentError, "Expected Hash or Liquid::Context as parameter"
      end
    end

    def tokenize(source)
      Tokenizer.new(source, @line_numbers)
    end

    def with_profiling(context)
      if @profiling && !context.partial
        raise "Profiler not loaded, require 'liquid/profiler' first" unless defined?(Liquid::Profiler)

        @profiler = Profiler.new(context.template_name)
        @profiler.start

        begin
          yield
        ensure
          @profiler.stop
        end
      else
        yield
      end
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
