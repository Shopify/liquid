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
    attr_accessor :filters, :name

    def initialize(markup)
      @markup  = markup
      @name    = nil
      @filters = []
      if match = markup.match(/\s*(#{QuotedFragment})/)
        @name = match[1]
        if markup.match(/#{FilterSeparator}\s*(.*)/)
          filters = Regexp.last_match(1).split(/#{FilterSeparator}/)
          filters.each do |f|    
            if matches = f.match(/\s*(\w+)/)
              filtername = matches[1]
              filterargs = f.scan(/(?:#{FilterArgumentSeparator}|#{ArgumentSeparator})\s*(#{QuotedFragment})/).flatten
              @filters << [filtername.to_sym, filterargs]
            end
          end
        end
      end
    end

    def render(context)
      return '' if @name.nil?
      output = context[@name]
      @filters.inject(output) do |output, filter|
        filterargs = filter[1].to_a.collect do |a|
         context[a]
        end
        begin
          output = context.invoke(filter[0], output, *filterargs)
        rescue FilterNotFound
          raise FilterNotFound, "Error - filter '#{filter[0]}' in '#{@markup.strip}' could not be found."
        end
      end
      output
    end
  end
end