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
    attr_accessor :filters, :name

    def initialize(markup)
      @markup  = markup
      @name    = nil
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
