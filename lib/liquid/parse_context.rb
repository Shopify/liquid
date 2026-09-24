# frozen_string_literal: true

module Liquid
  class ParseContext
    attr_accessor :locale, :line_number, :trim_whitespace, :depth
    attr_reader :partial, :warnings, :error_mode, :environment

    def initialize(options = Const::EMPTY_HASH)
      @environment = options.fetch(:environment, Environment.default)
      @template_options = options ? options.dup : {}

      @locale   = @template_options[:locale] ||= I18n.new
      @warnings = []

      # constructing new StringScanner in Lexer, Tokenizer, etc is expensive
      # This StringScanner will be shared by all of them
      @string_scanner = StringScanner.new("")

      @expression_cache = if options[:expression_cache].nil?
        {}
      elsif options[:expression_cache].respond_to?(:[]) && options[:expression_cache].respond_to?(:[]=)
        options[:expression_cache]
      elsif options[:expression_cache]
        {}
      end

      self.depth   = 0
      self.partial = false
    end

    def [](option_key)
      @options[option_key]
    end

    def new_block_body
      Liquid::BlockBody.new
    end

    def new_parser(input)
      @string_scanner.string = input
      Parser.new(
        @string_scanner,
        reject_bare_brackets: @error_mode == :strict2 || @error_mode == :rigid,
        allow_calls: @error_mode == :strict2,
      )
    end

    def new_tokenizer(source, start_line_number: nil, for_liquid_tag: false)
      Tokenizer.new(
        source: source,
        string_scanner: @string_scanner,
        line_number: start_line_number,
        for_liquid_tag: for_liquid_tag,
      )
    end

    def safe_parse_expression(parser)
      Expression.safe_parse(parser, @string_scanner, @expression_cache)
    end

    def parse_expression(markup, safe: false)
      if !safe && @error_mode == :strict2
        # parse_expression is a widely used API. To maintain backward
        # compatibility while raising awareness about strict2 parser standards,
        # the safe flag supports API users make a deliberate decision.
        #
        # In strict2 mode, markup MUST come from parser.expression, which returns
        # markup or a parsed callable node. We're not calling the parser here to
        # prevent redundant parser overhead.
        raise Liquid::InternalError, "unsafe parse_expression cannot be used in strict2 mode"
      end

      Expression.parse(markup, @string_scanner, @expression_cache)
    end

    def with_document_scope(&block)
      previous_usage = @uses_local_bindings
      @uses_local_bindings = false
      with_lexical_scope(&block)
      @uses_local_bindings
    ensure
      @uses_local_bindings = previous_usage
    end

    def with_lexical_scope(parameters = Const::EMPTY_ARRAY)
      previous_scope = @lexical_scope
      @lexical_scope = parameters.to_h { |name| [name, true] }
      yield
    ensure
      @lexical_scope = previous_scope
    end

    def local_declarations?
      @lexical_scope && !@lexical_scope.empty?
    end

    def declare_local(name)
      @lexical_scope ||= {}
      raise SyntaxError, "Duplicate let declaration '#{name}'" if @lexical_scope.key?(name)

      @lexical_scope[name] = true
    end

    def with_closure(parameters = Const::EMPTY_ARRAY, &block)
      require_closures!
      previous_closure = @in_closure
      @in_closure = true
      with_lexical_scope(parameters, &block)
    ensure
      @in_closure = previous_closure
    end

    def in_closure?
      @in_closure
    end

    def require_closures!
      @uses_local_bindings = true
      return if @error_mode == :strict2

      raise SyntaxError, "Closures require strict2 mode"
    end

    def partial=(value)
      @partial = value
      @options = value ? partial_options : @template_options

      @error_mode = @options[:error_mode] || @environment.error_mode
    end

    def partial_options
      @partial_options ||= begin
        dont_pass = @template_options[:include_options_blacklist]
        if dont_pass == true
          { locale: locale }
        elsif dont_pass.is_a?(Array)
          @template_options.reject { |k, _v| dont_pass.include?(k) }
        else
          @template_options
        end
      end
    end
  end
end
