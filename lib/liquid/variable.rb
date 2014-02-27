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
    FilterParser = /(?:#{FilterSeparator}|(?:\s*(?:#{QuotedFragment}|#{ArgumentSeparator})\s*)+)/o
    EasyParse = /\A *(\w+(?:\.\w+)*) *\z/
    attr_accessor :filters, :name, :warnings

    def initialize(markup, options = {})
      @markup  = markup
      @name    = nil
      @options = options || {}
      

      case @options[:error_mode] || Template.error_mode
      when :strict then strict_parse(markup)
      when :lax    then lax_parse(markup)
      when :warn
        begin
          strict_parse(markup)
        rescue SyntaxError => e
          @warnings ||= []
          @warnings << e
          lax_parse(markup)
        end
      end
    end

    def lax_parse(markup)
      @filters = []
      if match = markup.match(/\s*(#{QuotedFragment})(.*)/o)
        @name = match[1]
        if match[2].match(/#{FilterSeparator}\s*(.*)/o)
          filters = Regexp.last_match(1).scan(FilterParser)
          filters.each do |f|
            if matches = f.match(/\s*(\w+)/)
              filtername = matches[1]
              filterargs = f.scan(/(?:#{FilterArgumentSeparator}|#{ArgumentSeparator})\s*((?:\w+\s*\:\s*)?#{QuotedFragment})/o).flatten
              @filters << [filtername, filterargs]
            end
          end
        end
      end
    end

    def strict_parse(markup)
      # Very simple valid cases
      if markup =~ EasyParse
        @name = $1
        @filters = []
        return
      end

      @filters = []
      p = Parser.new(markup)
      # Could be just filters with no input
      @name = p.look(:pipe) ? '' : p.expression
      while p.consume?(:pipe)
        filtername = p.consume(:id)
        filterargs = p.consume?(:colon) ? parse_filterargs(p) : []
        @filters << [filtername, filterargs]
      end
      p.consume(:end_of_string)
    rescue SyntaxError => e
      e.message << " in \"{{#{markup}}}\""
      raise e
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
      return '' if @name.nil?
      @filters.inject(context[@name]) do |output, filter|
        filterargs = []
        keyword_args = {}
        filter[1].to_a.each do |a|
          if matches = a.match(/\A#{TagAttributes}\z/o)
            keyword_args[matches[1]] = context[matches[2]]
          else
            filterargs << context[a]
          end
        end
        filterargs << keyword_args unless keyword_args.empty?
        begin
          output = context.invoke(filter[0], output, *filterargs)
        rescue FilterNotFound
          raise FilterNotFound, "Error - filter '#{filter[0]}' in '#{@markup.strip}' could not be found."
        end
      end
    end
  end
end
