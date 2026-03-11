# frozen_string_literal: true

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
    # Checks if markup is a simple "name.lookup.chain" with no filters/brackets/quotes.
    # Returns the trimmed markup string, or nil if not simple.
    # Avoids regex MatchData allocation.
    def self.simple_variable_markup(markup)
      len = markup.bytesize
      return nil if len == 0

      # Skip leading whitespace
      pos = 0
      while pos < len
        b = markup.getbyte(pos)
        break unless b == 32 || b == 9 || b == 10 || b == 13
        pos += 1
      end
      return nil if pos >= len

      start = pos

      # First char must be [a-zA-Z_]
      b = markup.getbyte(pos)
      return nil unless (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || b == 95
      pos += 1

      # Scan segments: [\w-]* (. [\w-]*)*
      while pos < len
        b = markup.getbyte(pos)
        if (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || (b >= 48 && b <= 57) || b == 95 || b == 45
          pos += 1
        elsif b == 46 # '.'
          pos += 1
          # After dot, must have [a-zA-Z_]
          return nil if pos >= len
          b = markup.getbyte(pos)
          return nil unless (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || b == 95
          pos += 1
        else
          break
        end
      end

      content_end = pos

      # Skip trailing whitespace
      while pos < len
        b = markup.getbyte(pos)
        return nil unless b == 32 || b == 9 || b == 10 || b == 13
        pos += 1
      end

      # Must have consumed everything
      return nil unless pos == len

      if start == 0 && content_end == len
        markup
      else
        markup.byteslice(start, content_end - start)
      end
    end

    FilterMarkupRegex        = /#{FilterSeparator}\s*(.*)/om
    FilterParser             = /(?:\s+|#{QuotedFragment}|#{ArgumentSeparator})+/o
    FilterArgsRegex          = /(?:#{FilterArgumentSeparator}|#{ArgumentSeparator})\s*((?:\w+\s*\:\s*)?#{QuotedFragment})/o
    JustTagAttributes        = /\A#{TagAttributes}\z/o
    MarkupWithQuotedFragment = /(#{QuotedFragment})(.*)/om

    attr_accessor :filters, :name, :line_number
    attr_reader :parse_context
    alias_method :options, :parse_context

    include ParserSwitching

    def initialize(markup, parse_context)
      @markup        = markup
      @name          = nil
      @parse_context = parse_context
      @line_number   = parse_context.line_number

      # Fast path: try to parse without going through Lexer → Parser
      # Skip for strict2/rigid modes which require different parsing
      if parse_context.error_mode == :strict2 || parse_context.error_mode == :rigid || !try_fast_parse(markup, parse_context)
        strict_parse_with_error_mode_fallback(markup)
      end
    end

    private def try_fast_parse(markup, parse_context)
      len = markup.bytesize
      return false if len == 0

      # Skip leading whitespace
      pos = 0
      while pos < len
        b = markup.getbyte(pos)
        break unless b == 32 || b == 9 || b == 10 || b == 13
        pos += 1
      end
      return false if pos >= len

      # Check first byte: must be identifier start, quote, or digit for fast path
      b = markup.getbyte(pos)

      # Only handle identifier-started expressions (covers ~95% of variables)
      return false unless (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || b == 95

      # Scan the name portion: [\w-]*(\.[\w-]*)*
      name_start = pos
      pos += 1
      while pos < len
        b = markup.getbyte(pos)
        if (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || (b >= 48 && b <= 57) || b == 95 || b == 45
          pos += 1
        elsif b == 46 # '.'
          pos += 1
          return false if pos >= len
          b = markup.getbyte(pos)
          return false unless (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || b == 95
          pos += 1
        else
          break
        end
      end
      name_end = pos

      # Skip whitespace after name
      while pos < len
        b = markup.getbyte(pos)
        break unless b == 32 || b == 9 || b == 10 || b == 13
        pos += 1
      end

      # Resolve the name expression
      expr_markup = markup.byteslice(name_start, name_end - name_start)
      cache = parse_context.expression_cache
      ss = parse_context.string_scanner

      if Expression::LITERALS.key?(expr_markup)
        @name = Expression::LITERALS[expr_markup]
      elsif cache
        @name = cache[expr_markup] || (cache[expr_markup] = VariableLookup.parse(expr_markup, ss, cache).freeze)
      else
        @name = VariableLookup.parse(expr_markup, ss || StringScanner.new(""), nil).freeze
      end

      # End of markup? No filters.
      if pos >= len
        @filters = Const::EMPTY_ARRAY
        return true
      end

      # Must be a pipe for filters
      return false unless markup.getbyte(pos) == 124 # '|'

      # Parse filters using the standard path but skip the Lexer/Parser for the name
      # We reuse strict_parse's filter loop by creating a parser from the filter portion only
      @filters = []
      filter_markup = markup.byteslice(pos, len - pos)
      # Use the standard parser for the filter chain (still cheaper than re-lexing the whole thing)
      p = parse_context.new_parser(filter_markup)

      while p.consume?(:pipe)
        filtername = p.consume(:id)
        filterargs = p.consume?(:colon) ? parse_filterargs(p) : Const::EMPTY_ARRAY
        @filters << lax_parse_filter_expressions(filtername, filterargs)
      end
      p.consume(:end_of_string)
      @filters = Const::EMPTY_ARRAY if @filters.empty?
      true
    rescue SyntaxError
      # If fast parse fails, fall back to full parse
      @name = nil
      @filters = nil
      false
    end

    def raw
      @markup
    end

    def markup_context(markup)
      "in \"{{#{markup}}}\""
    end

    def lax_parse(markup)
      @filters = Const::EMPTY_ARRAY
      return unless markup =~ MarkupWithQuotedFragment

      name_markup   = Regexp.last_match(1)
      filter_markup = Regexp.last_match(2)
      @name         = parse_context.parse_expression(name_markup)
      if filter_markup =~ FilterMarkupRegex
        filters = Regexp.last_match(1).scan(FilterParser)
        filters.each do |f|
          next unless f =~ /\w+/
          filtername = Regexp.last_match(0)
          filterargs = f.scan(FilterArgsRegex).flatten
          @filters = [] if @filters.frozen?
          @filters << lax_parse_filter_expressions(filtername, filterargs)
        end
      end
    end

    def strict_parse(markup)
      @filters = Const::EMPTY_ARRAY
      p = @parse_context.new_parser(markup)

      return if p.look(:end_of_string)

      @name = parse_context.safe_parse_expression(p)
      while p.consume?(:pipe)
        @filters = [] if @filters.frozen?
        filtername = p.consume(:id)
        filterargs = p.consume?(:colon) ? parse_filterargs(p) : Const::EMPTY_ARRAY
        @filters << lax_parse_filter_expressions(filtername, filterargs)
      end
      p.consume(:end_of_string)
    end

    def strict2_parse(markup)
      @filters = Const::EMPTY_ARRAY
      p = @parse_context.new_parser(markup)

      return if p.look(:end_of_string)

      @name = parse_context.safe_parse_expression(p)
      while p.consume?(:pipe)
        @filters = [] if @filters.frozen?
        @filters << strict2_parse_filter_expressions(p)
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
      obj = context.evaluate(@name)

      @filters.each do |filter_name, filter_args, filter_kwargs|
        filter_args = evaluate_filter_expressions(context, filter_args, filter_kwargs)
        obj = context.invoke(filter_name, obj, *filter_args)
      end

      context.apply_global_filter(obj)
    end

    def render_to_output_buffer(context, output)
      # Fast path: no filters and no global filter
      if @filters.empty? && context.global_filter.nil?
        obj = context.evaluate(@name)
      else
        obj = render(context)
      end
      render_obj_to_output(obj, output)
      output
    end

    def render_obj_to_output(obj, output)
      if obj.instance_of?(String)
        output << obj
      elsif obj.nil?
        # Do nothing
      elsif obj.instance_of?(Array)
        obj.each do |o|
          render_obj_to_output(o, output)
        end
      else
        output << Liquid::Utils.to_s(obj)
      end
    end

    def disabled?(_context)
      false
    end

    def disabled_tags
      []
    end

    private

    def lax_parse_filter_expressions(filter_name, unparsed_args)
      filter_args  = []
      keyword_args = nil
      unparsed_args.each do |a|
        # Fast check: keyword args must contain ':'
        if a.include?(':') && (matches = a.match(JustTagAttributes))
          keyword_args           ||= {}
          keyword_args[matches[1]] = parse_context.parse_expression(matches[2])
        else
          filter_args << parse_context.parse_expression(a)
        end
      end
      result = [filter_name, filter_args]
      result << keyword_args if keyword_args
      result
    end

    # Surprisingly, positional and keyword arguments can be mixed.
    #
    # filter = filtername [":" filterargs?]
    # filterargs = argument ("," argument)*
    # argument = (positional_argument | keyword_argument)
    # positional_argument = expression
    # keyword_argument = id ":" expression
    def strict2_parse_filter_expressions(p)
      filtername = p.consume(:id)
      filter_args = []
      keyword_args = {}

      if p.consume?(:colon)
        # Parse first argument (no leading comma)
        argument(p, filter_args, keyword_args) unless end_of_arguments?(p)

        # Parse remaining arguments (with leading commas) and optional trailing comma
        argument(p, filter_args, keyword_args) while p.consume?(:comma) && !end_of_arguments?(p)
      end

      result = [filtername, filter_args]
      result << keyword_args unless keyword_args.empty?
      result
    end

    def argument(p, positional_arguments, keyword_arguments)
      if p.look(:id) && p.look(:colon, 1)
        key = p.consume(:id)
        p.consume(:colon)
        value = parse_context.safe_parse_expression(p)
        keyword_arguments[key] = value
      else
        positional_arguments << parse_context.safe_parse_expression(p)
      end
    end

    def end_of_arguments?(p)
      p.look(:pipe) || p.look(:end_of_string)
    end

    def evaluate_filter_expressions(context, filter_args, filter_kwargs)
      if filter_kwargs
        parsed_args = filter_args.map { |expr| context.evaluate(expr) }
        parsed_kwargs = {}
        filter_kwargs.each do |key, expr|
          parsed_kwargs[key] = context.evaluate(expr)
        end
        parsed_args << parsed_kwargs
        parsed_args
      elsif filter_args.empty?
        Const::EMPTY_ARRAY
      else
        filter_args.map { |expr| context.evaluate(expr) }
      end
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.name] + @node.filters.flatten
      end
    end
  end
end
