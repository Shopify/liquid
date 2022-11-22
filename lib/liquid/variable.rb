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

      strict_parse_with_error_mode_fallback(markup)
    end

    def raw
      @markup
    end

    def markup_context(markup)
      "in \"{{#{markup}}}\""
    end

    STRICT_PARSE_CONTEXT = ParseContext.new(error_mode: :strict)
    private_constant :STRICT_PARSE_CONTEXT

    def self.migrate(markup, parse_context)
      new(markup, STRICT_PARSE_CONTEXT)
      # TODO: migrate non-integer range expression literals
      markup
    rescue Liquid::SyntaxError
      raise if parse_context.error_mode == :strict
      lax_migrate(markup, parse_context)
    end

    def self.lax_migrate(markup, parse_context)
      # unanchored match that may skip over characters preceding the name expression
      markup_match = markup.match(MarkupWithQuotedFragment)
      unless markup_match
        # Treated as a blank variable (e.g. `{{ -}}`), which outputs nothing
        # but may still have an effect on whitespace trimming
        return ""
      end

      name_markup = markup_match[1]
      filters_markup = markup_match[2]

      new_name_markup = Expression.lax_migrate(name_markup)

      new_filter_markup = ""
      # unanchored match that may skip over characters preceding the pipe for the first filter
      if (filters_match = filters_markup.match(/\s*#{FilterMarkupRegex}/o))
        filters = filters_match[1].scan(FilterParser) # may skip over unterminated quote characters
        filters.map! do |f|
          filter_match = f.match(/\A(\s*)\W*(\w+)(\s*)/)
          next unless filter_match

          # omit non-word characters preceding the filter name that the lax parser skips over
          transformed_filter = +"#{filter_match[1]}#{filter_match[2]}#{filter_match[3]}"

          filter_args = []
          f.scan(/#{FilterArgsRegex}\s*/o) do # may skip over characters before the argument separator
            filter_arg_match = Regexp.last_match
            new_filter_arg = lax_migrate_filter_argument(filter_arg_match[1])
            filter_arg_string = Utils.match_captures_replace(filter_arg_match, 1 => new_filter_arg)
            filter_arg_string = filter_arg_string[1...] # remove separator character
            filter_args << filter_arg_string
          end

          unless filter_args.empty?
            transformed_filter << ":" << filter_args.join(",")
          end

          transformed_filter
        end
        filters.compact!
        new_filters_markup = filters.join('|')

        # include pipe separator along with whitespace surrounding it
        new_filter_markup = Utils.match_captures_replace(filters_match, 1 => new_filters_markup)
      end

      new_markup = Utils.match_captures_replace(markup_match, 1 => new_name_markup, 2 => new_filter_markup)
      new_markup.prepend(" ") if markup_match.begin(0) > 0
      new_markup
    end

    def self.lax_migrate_filter_argument(unparsed_arg)
      if (match = unparsed_arg.match(JustTagAttributes))
        new_value_markup = Expression.lax_migrate(match[2])
        Utils.match_captures_replace(match, 2 => new_value_markup)
      else
        Expression.lax_migrate(unparsed_arg)
      end
    end

    def lax_parse(markup)
      @filters = []
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
          @filters << parse_filter_expressions(filtername, filterargs)
        end
      end
    end

    def strict_parse(markup)
      @filters = []
      p = Parser.new(markup)

      return if p.look(:end_of_string)

      @name = parse_context.parse_expression(p.expression)
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
      obj = context.evaluate(@name)

      @filters.each do |filter_name, filter_args, filter_kwargs|
        filter_args = evaluate_filter_expressions(context, filter_args, filter_kwargs)
        obj = context.invoke(filter_name, obj, *filter_args)
      end

      context.apply_global_filter(obj)
    end

    def render_to_output_buffer(context, output)
      obj = render(context)

      if obj.is_a?(Array)
        output << obj.join
      elsif obj.nil?
      else
        output << obj.to_s
      end

      output
    end

    def disabled?(_context)
      false
    end

    def disabled_tags
      []
    end

    private

    def parse_filter_expressions(filter_name, unparsed_args)
      filter_args  = []
      keyword_args = nil
      unparsed_args.each do |a|
        if (matches = a.match(JustTagAttributes))
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

    def evaluate_filter_expressions(context, filter_args, filter_kwargs)
      parsed_args = filter_args.map { |expr| context.evaluate(expr) }
      if filter_kwargs
        parsed_kwargs = {}
        filter_kwargs.each do |key, expr|
          parsed_kwargs[key] = context.evaluate(expr)
        end
        parsed_args << parsed_kwargs
      end
      parsed_args
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.name] + @node.filters.flatten
      end
    end
  end
end
