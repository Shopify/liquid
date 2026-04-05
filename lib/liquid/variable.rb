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
    def self.simple_variable_markup(markup)
      return if markup.empty?
      return unless markup.match?(SIMPLE_VARIABLE_RE)
      # Avoid allocation when there's no surrounding whitespace (the common case)
      first = markup.getbyte(0)
      last  = markup.getbyte(markup.bytesize - 1)
      needs_strip = first == Cursor::SPACE || first == Cursor::TAB || first == Cursor::NL || first == Cursor::CR ||
        last == Cursor::SPACE || last == Cursor::TAB || last == Cursor::NL || last == Cursor::CR
      needs_strip ? markup.strip : markup
    end

    # Cache for [filtername, EMPTY_ARRAY] tuples — avoids repeated array creation
    NO_ARG_FILTER_CACHE = Hash.new { |h, k| h[k] = [k, Const::EMPTY_ARRAY].freeze }

    # Regex for a simple variable lookup with optional surrounding whitespace.
    # Shares the identifier grammar with VariableLookup::SIMPLE_LOOKUP_RE.
    SIMPLE_VARIABLE_RE = /\A\s*[\w-]+\??(?:\.[\w-]+\??)*\s*\z/

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
      # Fast path only for lax/warn modes — strict modes need full error checking
      error_mode = parse_context.error_mode
      if error_mode == :strict2 || error_mode == :rigid || error_mode == :strict || !try_fast_parse(markup, parse_context)
        strict_parse_with_error_mode_fallback(markup)
      end
    end

    private def try_fast_parse(markup, parse_context)
      pos = fast_scan_name(markup)
      return false unless pos

      # fast_resolve_name calls VariableLookup.parse_simple / Expression::LITERALS — the
      # only sites that can raise SyntaxError on malformed input. The byte scanners return
      # false instead of raising.
      begin
        fast_resolve_name(markup, parse_context)
      rescue SyntaxError
        return false
      end

      # End of markup — no filters
      if pos >= markup.bytesize
        @filters = Const::EMPTY_ARRAY
        return true
      end

      # Must be followed by a pipe filter separator
      return false unless markup.getbyte(pos) == Cursor::PIPE

      fast_scan_filters(markup, pos, parse_context)
    end

    # Scan the variable name (quoted string or identifier chain) at the start of markup.
    # Returns the position after the name + trailing whitespace, or false on failure.
    # Sets @_fast_name_start and @_fast_name_end for fast_resolve_name.
    private def fast_scan_name(markup)
      len = markup.bytesize
      return false if len == 0

      # Skip leading whitespace
      pos = 0
      while pos < len
        b = markup.getbyte(pos)
        break unless b == Cursor::SPACE || b == Cursor::TAB || b == Cursor::NL || b == Cursor::CR
        pos += 1
      end
      return false if pos >= len

      b = markup.getbyte(pos)

      if b == Cursor::QUOTE_S || b == Cursor::QUOTE_D
        # Quoted string literal: scan to matching close quote
        quote = b
        @_fast_name_start = pos
        pos += 1
        pos += 1 while pos < len && markup.getbyte(pos) != quote
        pos += 1 if pos < len # skip closing quote
        @_fast_name_end = pos
      elsif ByteTables::IDENT_START[b]
        # Identifier chain: [a-zA-Z_][a-zA-Z0-9_-]*(.[a-zA-Z_][a-zA-Z0-9_-]*)*
        @_fast_name_start = pos
        pos += 1
        while pos < len
          b = markup.getbyte(pos)
          if ByteTables::IDENT_CONT[b]
            pos += 1
          elsif b == Cursor::DOT
            pos += 1
            return false if pos >= len
            b = markup.getbyte(pos)
            return false unless ByteTables::IDENT_START[b]
            pos += 1
          else
            break
          end
        end
        @_fast_name_end = pos
      else
        return false
      end

      # Skip whitespace after name
      while pos < len
        b = markup.getbyte(pos)
        break unless b == Cursor::SPACE || b == Cursor::TAB || b == Cursor::NL || b == Cursor::CR
        pos += 1
      end

      pos
    end

    # Resolve the scanned name bytes to a Liquid expression object.
    # Reads @_fast_name_start / @_fast_name_end set by fast_scan_name.
    # Sets @name.  May raise SyntaxError (rescued in try_fast_parse).
    private def fast_resolve_name(markup, parse_context)
      name_start = @_fast_name_start
      name_end   = @_fast_name_end
      len        = markup.bytesize

      # Avoid byteslice when the name spans the whole markup (no surrounding whitespace/filters)
      expr_markup = name_start == 0 && name_end == len ? markup : markup.byteslice(name_start, name_end - name_start)

      cache = parse_context.expression_cache
      ss    = parse_context.string_scanner

      first_byte = expr_markup.getbyte(0)
      @name = if first_byte == Cursor::QUOTE_S || first_byte == Cursor::QUOTE_D
        # String literal — strip enclosing quotes
        expr_markup.byteslice(1, expr_markup.bytesize - 2)
      elsif Expression::LITERALS.key?(expr_markup)
        Expression::LITERALS[expr_markup]
      elsif cache
        cache[expr_markup] || (cache[expr_markup] = VariableLookup.parse_simple(expr_markup, ss, cache).freeze)
      else
        VariableLookup.parse_simple(expr_markup, ss || StringScanner.new(""), nil).freeze
      end
    end

    # Scan the filter chain starting at `pos` (the first '|').
    # Returns true on success (sets @filters), false to fall back to the Lexer.
    # Rescues SyntaxError from Expression.parse inside fast_scan_filter_args.
    private def fast_scan_filters(markup, pos, parse_context)
      len = markup.bytesize
      @filters = []
      filter_pos = pos

      while filter_pos < len && markup.getbyte(filter_pos) == Cursor::PIPE
        filter_pos += 1
        # Skip spaces after pipe (tabs/newlines handled in the between-filters skip below)
        filter_pos += 1 while filter_pos < len && markup.getbyte(filter_pos) == Cursor::SPACE

        # Scan filter name: must start with [a-zA-Z_]
        fname_start = filter_pos
        b = filter_pos < len ? markup.getbyte(filter_pos) : nil
        break unless b && ByteTables::IDENT_START[b]
        filter_pos += 1
        while filter_pos < len
          b = markup.getbyte(filter_pos)
          break unless ByteTables::IDENT_CONT[b]
          filter_pos += 1
        end
        filtername = markup.byteslice(fname_start, filter_pos - fname_start)

        # Skip whitespace after filter name
        filter_pos += 1 while filter_pos < len && markup.getbyte(filter_pos) == Cursor::SPACE

        if filter_pos < len && markup.getbyte(filter_pos) == Cursor::COLON
          # Has arguments — fast-scan positional args; fall to Lexer on keyword args
          filter_pos += 1 # skip ':'
          filter_pos += 1 while filter_pos < len && markup.getbyte(filter_pos) == Cursor::SPACE

          result = fast_scan_filter_args(markup, filter_pos, parse_context)
          return fall_to_lexer_filters(markup, pos, fname_start, len, parse_context) if result == :fall_to_lexer

          filter_args, filter_pos = result
          @filters << [filtername, filter_args]
        else
          # No-arg filter — reuse the cached [name, EMPTY_ARRAY] tuple
          @filters << NO_ARG_FILTER_CACHE[filtername]
        end

        # Skip whitespace (including tabs and newlines) between filters
        filter_pos += 1 while filter_pos < len && (
          markup.getbyte(filter_pos) == Cursor::SPACE ||
          markup.getbyte(filter_pos) == Cursor::TAB   ||
          markup.getbyte(filter_pos) == Cursor::NL    ||
          markup.getbyte(filter_pos) == Cursor::CR
        )
      end

      # Trailing bytes that aren't a pipe mean something the fast path doesn't handle
      return false if filter_pos < len

      @filters = Const::EMPTY_ARRAY if @filters.empty?
      true
    rescue SyntaxError
      # Expression.parse (called inside fast_scan_filter_args for identifier args) can
      # raise SyntaxError on malformed input.  Fall back to full Lexer parse.
      @name = nil
      @filters = nil
      false
    end

    # Called when fast_scan_filter_args encounters keyword args or an unrecognised
    # token. Hands the remaining filter chain (from the pipe before fname_start)
    # to the full Lexer-based parser, merges results into @filters, and returns true.
    private def fall_to_lexer_filters(markup, pos, fname_start, len, parse_context)
      # Walk back from fname_start to find the pipe that opened this filter.
      # Equivalent to: markup.rindex('|', fname_start), bounded by pos.
      rest_start = fname_start
      rest_start -= 1 while rest_start > pos && markup.getbyte(rest_start) != Cursor::PIPE
      rest_markup = markup.byteslice(rest_start, len - rest_start)
      p = parse_context.new_parser(rest_markup)
      while p.consume?(:pipe)
        fn = p.consume(:id)
        fa = p.consume?(:colon) ? parse_filterargs(p) : Const::EMPTY_ARRAY
        @filters << lax_parse_filter_expressions(fn, fa)
      end
      p.consume(:end_of_string)
      @filters = Const::EMPTY_ARRAY if @filters.empty?
      true
    end

    # Scan positional filter arguments starting at `filter_pos`.
    # Returns [filter_args_array, new_filter_pos] on success, or :fall_to_lexer when
    # keyword args or unrecognised tokens are encountered.
    private def fast_scan_filter_args(markup, filter_pos, parse_context)
      len = markup.bytesize
      filter_args = []

      loop do
        arg_start = filter_pos
        b = filter_pos < len ? markup.getbyte(filter_pos) : nil

        if b == Cursor::QUOTE_S || b == Cursor::QUOTE_D
          # Quoted string argument
          quote = b
          filter_pos += 1
          filter_pos += 1 while filter_pos < len && markup.getbyte(filter_pos) != quote
          filter_pos += 1 if filter_pos < len # skip closing quote
          filter_args << markup.byteslice(arg_start + 1, filter_pos - arg_start - 2)

        elsif b && (ByteTables::DIGIT[b] ||
                    (b == Cursor::DASH && filter_pos + 1 < len && ByteTables::DIGIT[markup.getbyte(filter_pos + 1)]))
          # Numeric argument (integer or float, optionally negative)
          filter_pos += 1 if b == Cursor::DASH
          filter_pos += 1 while filter_pos < len && ByteTables::DIGIT[markup.getbyte(filter_pos)]
          if filter_pos < len && markup.getbyte(filter_pos) == Cursor::DOT # float
            filter_pos += 1
            filter_pos += 1 while filter_pos < len && ByteTables::DIGIT[markup.getbyte(filter_pos)]
          end
          num_str = markup.byteslice(arg_start, filter_pos - arg_start)
          filter_args << (num_str.include?('.') ? num_str.to_f : num_str.to_i)

        elsif b && ByteTables::IDENT_START[b]
          # Identifier argument — may be a variable lookup or keyword arg
          id_start = filter_pos
          filter_pos += 1
          while filter_pos < len
            b2 = markup.getbyte(filter_pos)
            break unless ByteTables::IDENT_CONT[b2] || b2 == Cursor::DOT
            filter_pos += 1
          end
          filter_pos += 1 if filter_pos < len && markup.getbyte(filter_pos) == Cursor::QMARK

          # Peek past whitespace: if followed by ':', this is a keyword arg → fall to Lexer
          kw_check = filter_pos
          kw_check += 1 while kw_check < len && markup.getbyte(kw_check) == Cursor::SPACE
          return :fall_to_lexer if kw_check < len && markup.getbyte(kw_check) == Cursor::COLON

          id_markup = markup.byteslice(id_start, filter_pos - id_start)
          filter_args << Expression.parse(id_markup, parse_context.string_scanner, parse_context.expression_cache)

        else
          return :fall_to_lexer
        end

        # Skip whitespace after argument
        filter_pos += 1 while filter_pos < len && markup.getbyte(filter_pos) == Cursor::SPACE

        # Comma: more arguments follow; anything else: done with this filter's args
        if filter_pos < len && markup.getbyte(filter_pos) == Cursor::COMMA
          filter_pos += 1
          filter_pos += 1 while filter_pos < len && markup.getbyte(filter_pos) == Cursor::SPACE
        else
          break
        end
      end

      [filter_args, filter_pos]
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
        if filter_args.empty? && !filter_kwargs
          obj = context.invoke_single(filter_name, obj)
        elsif !filter_kwargs && filter_args.length == 1
          # Single positional arg — most common after no-arg
          obj = context.invoke_two(filter_name, obj, context.evaluate(filter_args[0]))
        else
          filter_args = evaluate_filter_expressions(context, filter_args, filter_kwargs)
          obj = context.invoke(filter_name, obj, *filter_args)
        end
      end

      context.apply_global_filter(obj)
    end

    def render_to_output_buffer(context, output)
      # Fast path: no filters and no global filter
      obj = if @filters.empty? && context.global_filter.nil?
        context.evaluate(@name)
      else
        render(context)
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
      Const::EMPTY_ARRAY
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
