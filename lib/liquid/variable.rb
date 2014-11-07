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
    FilterParser = /(?:\s+|#{QuotedFragment}|#{ArgumentSeparator})+/o
    EasyParse = /\A *(\w+(?:\.\w+)*) *\z/
    attr_accessor :filters, :name, :warnings
    attr_accessor :line_number
    include ParserSwitching

    def initialize(markup, options = {})
      @markup  = markup
      @name    = nil
      @options = options || {}

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
      if markup =~ /(#{QuotedFragment})(.*)/om
        name_markup = $1
        filter_markup = $2
        @name = Expression.parse(name_markup)
        if filter_markup =~ /#{FilterSeparator}\s*(.*)/om
          filters = $1.scan(FilterParser)
          filters.each do |f|
            if f =~ /\w+/
              filtername = Regexp.last_match(0)
              filterargs = f.scan(/(?:#{FilterArgumentSeparator}|#{ArgumentSeparator})\s*((?:\w+\s*\:\s*)?#{QuotedFragment})/o).flatten
              @filters << parse_filter_expressions(filtername, filterargs)
            end
          end
        end
      end
    end

    def strict_parse(markup)
      # Very simple valid cases
      if markup =~ EasyParse
        @name = Expression.parse($1)
        @filters = []
        return
      end

      @filters = []
      p = Parser.new(markup)
      # Could be just filters with no input
      @name = p.look(:pipe) ? nil : Expression.parse(p.expression)
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
      while p.consume?(:comma)
        filterargs << p.argument
      end
      filterargs
    end

    def render(context)
      @filters.inject(context.evaluate(@name)) do |output, (filter_name, filter_args, filter_kwargs)|
        filter_args = evaluate_filter_expressions(context, filter_args, filter_kwargs)
        output = context.invoke(filter_name, output, *filter_args)
      end.tap{ |obj| taint_check(obj) }
    end

    private

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

    def taint_check(obj)
      if obj.tainted?
        @markup =~ QuotedFragment
        name = Regexp.last_match(0)
        case Template.taint_mode
        when :warn
          @warnings ||= []
          @warnings << "variable '#{name}' is tainted and was not escaped"
        when :error
          raise TaintedError, "Error - variable '#{name}' is tainted and was not escaped"
        end
      end
    end
  end
end
