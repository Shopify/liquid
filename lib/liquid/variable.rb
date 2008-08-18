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
    FilterParser = /(?:#{FilterSeparator}|(?:\s*(?!(?:#{FilterSeparator}))(?:#{QuotedFragment}|\S+)\s*)+)/
    attr_accessor :filters, :name

    def initialize(markup)
      @markup  = markup
      @name    = nil
      @filters = []
      if match = markup.match(/\s*(#{QuotedFragment})(.*)/)
        @name = match[1]
        if match[2].match(/#{FilterSeparator}\s*(.*)/)
          filters = Regexp.last_match(1).scan(FilterParser)
          filters.each do |f|
            next unless f.match(/\s*\w+/)
            filtername = nil
            filterargs = []
            filteropts = {}
            Scanner.scan(f) do |s|
              s.skip_opt_whitespace
              filtername = s.require(/\w+/, "could not find filter name")
              s.skip_opt_whitespace
              if s.scan(/:/)
                s.skip_opt_whitespace
                begin
                  if s.scan(TagAttributes)
                    filteropts[s[1]] = s[2]
                  elsif s.scan(QuotedFragment)
                    if filteropts.empty?
                      filterargs << s.matched
                    else
                      raise SyntaxError, "filter argument '#{s.matched}' must precede attributes"
                    end
                  else
                    raise SyntaxError, "filter arguments could not be recognised at '#{s.rest}'"
                  end
                end while s.scan(/,\s*/)
                filterargs << filteropts unless filteropts.empty?
              elsif !s.eos?
                raise SyntaxError, "trailing content '#{s.rest}' could not be recognised - you need to use ':' to introduce the argument list"
              end
            end
            @filters << [filtername.to_sym, filterargs]
          end
        end
      end
    end

    def render(context)
      return '' if @name.nil?
      @filters.inject(context[@name]) do |output, filter|
        filterargs = filter[1].to_a.collect do |a|
          resolve_argument(a, context)
        end
        begin
          output = context.invoke(filter[0], output, *filterargs)
        rescue FilterNotFound
          raise FilterNotFound, "Error - filter '#{filter[0]}' in '#{@markup.strip}' could not be found."
        end
      end
    end

    private
      def resolve_argument(arg, context)
        if arg.is_a?(Hash)
          Hash[*(arg.map { |key, value| [key, context[value]] }.flatten)]
        else
          context[arg]
        end
      end
  end
end
