module Liquid
  # Holds variables. Variables are only loaded "just in time"
  # and are not evaluated as part of the render stage
  #
  #   {{ monkey }}
  #   {{ user.name }}
  #
  # Variables can be combined with filters:
  #
  #   {{ user | link }}
  #
  class Variable
    capture_ignored_variable_prefix = /([\s,\|'"]+?)??/
    capture_expression = /(#{QuotedFragment})/o
    capture_ignored_filter_prefix = /([^\|]+?)??/
    capture_filters = /(#{FilterSeparator}.*)/o
    VariableSyntax = /\A\s*#{capture_ignored_variable_prefix}\s*#{capture_expression}\s*(?:#{capture_ignored_filter_prefix}\s*#{capture_filters})?\z/om

    capture_lax_separator = /(['"\|]+?)/
    capture_filter = /((?:\s+|#{QuotedFragment}|#{ArgumentSeparator})+)/o
    FilterParser = /\s*(?:#{FilterSeparator}|#{capture_lax_separator})\s*#{capture_filter}/o

    attr_accessor :filters, :name, :line_number
    attr_reader :parse_context
    alias_method :options, :parse_context
    include ParserSwitching

    def initialize(markup, parse_context)
      @markup  = markup
      @name    = nil
      @parse_context = parse_context
      @line_number = parse_context.line_number

      parse_with_selected_parser(markup)
    end

    def raw
      @markup
    end

    def markup_context(markup)
      "in \"{{#{markup}}}\""
    end

    def lax_parse(markup)
      @filters = []
      return unless markup =~ VariableSyntax

      add_syntax_warning("variable prefixed with ignored characters: #{$1.inspect}") if $1
      name_markup = $2
      add_syntax_warning("variable filter separator prefixed with ignored characters: #{$3.inspect}") if $3
      filters_markup = $4
      @name = Expression.parse(name_markup)
      if filters_markup
        filters_markup.scan(FilterParser) do |lax_sep, f|
          add_syntax_warning("unterminated quote or multiple pipe characters used as a filter separator: #{lax_sep.inspect}") if lax_sep
          next unless f =~ /\A\s*(\W+)??(\w+)/
          add_syntax_warning("ignored characters before filter name: #{$1.inspect}") if $1
          filtername = $2
          filterargs = f.scan(/(?:#{FilterArgumentSeparator}|#{ArgumentSeparator})\s*((?:\w+\s*\:\s*)?#{QuotedFragment})/o).flatten
          @filters << parse_filter_expressions(filtername, filterargs)
        end
      end
    end

    def strict_parse(markup)
      @filters = []
      p = Parser.new(markup)

      @name = Expression.parse(p.expression)
      while p.consume?(:pipe)
        filtername = p.consume(:id)
        filterargs = p.consume?(:colon) ? parse_filterargs(p) : []
        @filters << parse_filter_expressions(filtername, filterargs)
      end
      p.consume(:end_of_string)
    end

    def parse_filterargs(p)
      # first argument
      filterargs = [p.argument]
      # followed by comma separated others
      filterargs << p.argument while p.consume?(:comma)
      filterargs
    end

    def render(context)
      obj = @filters.inject(context.evaluate(@name)) do |output, (filter_name, filter_args, filter_kwargs)|
        filter_args = evaluate_filter_expressions(context, filter_args, filter_kwargs)
        context.invoke(filter_name, output, *filter_args)
      end

      obj = context.apply_global_filter(obj)

      taint_check(context, obj)

      obj
    end

    private

    def add_syntax_warning(warning)
      return unless parse_context.error_mode == :lax_warn
      error = SyntaxError.new(warning)
      error.line_number = parse_context.line_number
      parse_context.warnings << error
    end

    def parse_filter_expressions(filter_name, unparsed_args)
      filter_args = []
      keyword_args = {}
      unparsed_args.each do |a|
        if matches = a.match(/\A#{TagAttributes}\z/o)
          keyword_args[matches[1]] = Expression.parse(matches[2])
        else
          filter_args << Expression.parse(a)
        end
      end
      result = [filter_name, filter_args]
      result << keyword_args unless keyword_args.empty?
      result
    end

    def evaluate_filter_expressions(context, filter_args, filter_kwargs)
      parsed_args = filter_args.map{ |expr| context.evaluate(expr) }
      if filter_kwargs
        parsed_kwargs = {}
        filter_kwargs.each do |key, expr|
          parsed_kwargs[key] = context.evaluate(expr)
        end
        parsed_args << parsed_kwargs
      end
      parsed_args
    end

    def taint_check(context, obj)
      return unless obj.tainted?
      return if Template.taint_mode == :lax

      @markup =~ QuotedFragment
      name = Regexp.last_match(0)

      error = TaintedError.new("variable '#{name}' is tainted and was not escaped")
      error.line_number = line_number
      error.template_name = context.template_name

      case Template.taint_mode
      when :warn
        context.warnings << error
      when :error
        raise error
      end
    end
  end
end
