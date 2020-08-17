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

    attr_accessor :name, :line_number
    attr_reader :parse_context
    alias_method :options, :parse_context

    include ParserSwitching

    def initialize(markup, parse_context)
      @markup        = markup
      @name          = nil
      @parse_context = parse_context
      @line_number   = parse_context.line_number

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
      return unless markup =~ MarkupWithQuotedFragment

      name_markup   = Regexp.last_match(1)
      filter_markup = Regexp.last_match(2)
      @name         = Expression.parse(name_markup)
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
      result = context.evaluate(@name)
      @filters.each do |filter_name, constant_args, filter_args, filter_kwargs|
        unless constant_args
          filter_args = evaluate_filter_expressions(context, filter_args, filter_kwargs)
        end
        result = context.invoke_filter(filter_name, result, filter_args)
      end

      context.apply_global_filter(result)
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

    def filters
      @filters.map do |filter_name, constant_args, *filter_args_and_kwargs|
        filter_name = filter_name.to_s
        if constant_args
          filter_args = filter_args_and_kwargs.first
          if filter_args.last.is_a?(Hash)
            filter_args = filter_args.dup
            [filter_name, filter_args, filter_args.pop]
          else
            [filter_name, *filter_args_and_kwargs]
          end
        else
          [filter_name, *filter_args_and_kwargs]
        end
      end
    end

    private

    def parse_filter_expressions(filter_name, unparsed_args)
      constant_args = true
      filter_args = []
      keyword_args = nil
      unparsed_args.each do |a|
        if (matches = a.match(JustTagAttributes))
          keyword_args ||= {}
          expression = Expression.parse(matches[2])
          constant_args &&= !expression.is_a?(VariableLookup)
          keyword_args[matches[1]] = expression
        else
          expression = Expression.parse(a)
          constant_args &&= !expression.is_a?(VariableLookup)
          filter_args << expression
        end
      end
      result = [filter_name.to_sym, constant_args, filter_args]
      if keyword_args
        if constant_args
          filter_args << keyword_args
        else
          result << keyword_args
        end
      end
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
