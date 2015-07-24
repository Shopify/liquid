require 'cgi'
require 'bigdecimal'

module Liquid

  module StandardFilters
    HTML_ESCAPE = {
      '&'.freeze => '&amp;'.freeze,
      '>'.freeze => '&gt;'.freeze,
      '<'.freeze => '&lt;'.freeze,
      '"'.freeze => '&quot;'.freeze,
      "'".freeze => '&#39;'.freeze
    }
    HTML_ESCAPE_ONCE_REGEXP = /["><']|&(?!([a-zA-Z]+|(#\d+));)/

    # Return the size of an array or of an string
    def size(input)
      input.respond_to?(:size) ? input.size : 0
    end

    # convert an input string to DOWNCASE
    def downcase(input)
      input.to_s.downcase
    end

    # convert an input string to UPCASE
    def upcase(input)
      input.to_s.upcase
    end

    # capitalize words in the input centence
    def capitalize(input)
      input.to_s.capitalize
    end

    def escape(input)
      CGI.escapeHTML(input).untaint rescue input
    end
    alias_method :h, :escape

    def escape_once(input)
      input.to_s.gsub(HTML_ESCAPE_ONCE_REGEXP, HTML_ESCAPE)
    end

    def url_encode(input)
      CGI.escape(input) rescue input
    end

    def slice(input, offset, length=nil)
      offset = Integer(offset)
      length = length ? Integer(length) : 1

      if input.is_a?(Array)
        input.slice(offset, length) || []
      else
        input.to_s.slice(offset, length) || ''
      end
    end

    # Truncate a string down to x characters
    def truncate(input, length = 50, truncate_string = "...".freeze)
      if input.nil? then return end
      l = length.to_i - truncate_string.length
      l = 0 if l < 0
      input.length > length.to_i ? input[0...l] + truncate_string : input
    end

    def truncatewords(input, words = 15, truncate_string = "...".freeze)
      if input.nil? then return end
      wordlist = input.to_s.split
      l = words.to_i - 1
      l = 0 if l < 0
      wordlist.length > l ? wordlist[0..l].join(" ".freeze) + truncate_string : input
    end

    # Split input string into an array of substrings separated by given pattern.
    #
    # Example:
    #   <div class="summary">{{ post | split '//' | first }}</div>
    #
    def split(input, pattern)
      input.to_s.split(pattern)
    end

    def strip(input)
      input.to_s.strip
    end

    def lstrip(input)
      input.to_s.lstrip
    end

    def rstrip(input)
      input.to_s.rstrip
    end

    def strip_html(input)
      empty = ''.freeze
      input.to_s.gsub(/<script.*?<\/script>/m, empty).gsub(/<!--.*?-->/m, empty).gsub(/<style.*?<\/style>/m, empty).gsub(/<.*?>/m, empty)
    end

    # Remove all newlines from the string
    def strip_newlines(input)
      input.to_s.gsub(/\r?\n/, ''.freeze)
    end

    # Join elements of the array with certain character between them
    def join(input, glue = ' '.freeze)
      InputIterator.new(input).join(glue)
    end

    # Sort elements of the array
    # provide optional property with which to sort an array of hashes or drops
    def sort(input, property = nil)
      ary = InputIterator.new(input)
      if property.nil?
        ary.sort
      elsif ary.first.respond_to?(:[]) && !ary.first[property].nil?
        ary.sort {|a,b| a[property] <=> b[property] }
      elsif ary.first.respond_to?(property)
        ary.sort {|a,b| a.send(property) <=> b.send(property) }
      end
    end

    # Remove duplicate elements from an array
    # provide optional property with which to determine uniqueness
    def uniq(input, property = nil)
      ary = InputIterator.new(input)
      if property.nil?
        input.uniq
      elsif input.first.respond_to?(:[])
        input.uniq{ |a| a[property] }
      end
    end

    # Reverse the elements of an array
    def reverse(input)
      ary = InputIterator.new(input)
      ary.reverse
    end

    # map/collect on a given property
    def map(input, property)
      InputIterator.new(input).map do |e|
        e = e.call if e.is_a?(Proc)

        if property == "to_liquid".freeze
          e
        elsif e.respond_to?(:[])
          e[property]
        end
      end
    end

    # Replace occurrences of a string with another
    def replace(input, string, replacement = ''.freeze)
      input.to_s.gsub(string, replacement.to_s)
    end

    # Replace the first occurrences of a string with another
    def replace_first(input, string, replacement = ''.freeze)
      input.to_s.sub(string, replacement.to_s)
    end

    # remove a substring
    def remove(input, string)
      input.to_s.gsub(string, ''.freeze)
    end

    # remove the first occurrences of a substring
    def remove_first(input, string)
      input.to_s.sub(string, ''.freeze)
    end

    # add one string to another
    def append(input, string)
      input.to_s + string.to_s
    end

    # prepend a string to another
    def prepend(input, string)
      string.to_s + input.to_s
    end

    # Add <br /> tags in front of all newlines in input string
    def newline_to_br(input)
      input.to_s.gsub(/\n/, "<br />\n".freeze)
    end

    # Reformat a date using Ruby's core Time#strftime( string ) -> string
    #
    #   %a - The abbreviated weekday name (``Sun'')
    #   %A - The  full  weekday  name (``Sunday'')
    #   %b - The abbreviated month name (``Jan'')
    #   %B - The  full  month  name (``January'')
    #   %c - The preferred local date and time representation
    #   %d - Day of the month (01..31)
    #   %H - Hour of the day, 24-hour clock (00..23)
    #   %I - Hour of the day, 12-hour clock (01..12)
    #   %j - Day of the year (001..366)
    #   %m - Month of the year (01..12)
    #   %M - Minute of the hour (00..59)
    #   %p - Meridian indicator (``AM''  or  ``PM'')
    #   %s - Number of seconds since 1970-01-01 00:00:00 UTC.
    #   %S - Second of the minute (00..60)
    #   %U - Week  number  of the current year,
    #           starting with the first Sunday as the first
    #           day of the first week (00..53)
    #   %W - Week  number  of the current year,
    #           starting with the first Monday as the first
    #           day of the first week (00..53)
    #   %w - Day of the week (Sunday is 0, 0..6)
    #   %x - Preferred representation for the date alone, no time
    #   %X - Preferred representation for the time alone, no date
    #   %y - Year without a century (00..99)
    #   %Y - Year with century
    #   %Z - Time zone name
    #   %% - Literal ``%'' character
    #
    #   See also: http://www.ruby-doc.org/core/Time.html#method-i-strftime
    def date(input, format)
      return input if format.to_s.empty?

      return input unless date = to_date(input)

      date.strftime(format.to_s)
    end

    # Get the first element of the passed in array
    #
    # Example:
    #    {{ product.images | first | to_img }}
    #
    def first(array)
      array.first if array.respond_to?(:first)
    end

    # Get the last element of the passed in array
    #
    # Example:
    #    {{ product.images | last | to_img }}
    #
    def last(array)
      array.last if array.respond_to?(:last)
    end

    # addition
    def plus(input, operand)
      apply_operation(input, operand, :+)
    end

    # subtraction
    def minus(input, operand)
      apply_operation(input, operand, :-)
    end

    # multiplication
    def times(input, operand)
      apply_operation(input, operand, :*)
    end

    # division
    def divided_by(input, operand)
      apply_operation(input, operand, :/)
    end

    def modulo(input, operand)
      apply_operation(input, operand, :%)
    end

    def round(input, n = 0)
      result = to_number(input).round(to_number(n))
      result = result.to_f if result.is_a?(BigDecimal)
      result = result.to_i if n == 0
      result
    end

    def ceil(input)
      to_number(input).ceil.to_i
    end

    def floor(input)
      to_number(input).floor.to_i
    end

    def default(input, default_value = "".freeze)
      is_blank = input.respond_to?(:empty?) ? input.empty? : !input
      is_blank ? default_value : input
    end

    private

    def to_number(obj)
      case obj
      when Float
        BigDecimal.new(obj.to_s)
      when Numeric
        obj
      when String
        (obj.strip =~ /\A\d+\.\d+\z/) ? BigDecimal.new(obj) : obj.to_i
      else
        0
      end
    end

    def to_date(obj)
      return obj if obj.respond_to?(:strftime)

      case obj
      when 'now'.freeze, 'today'.freeze
        Time.now
      when /\A\d+\z/, Integer
        Time.at(obj.to_i)
      when String
        Time.parse(obj)
      else
        nil
      end
    rescue ::ArgumentError
      nil
    end

    def apply_operation(input, operand, operation)
      result = to_number(input).send(operation, to_number(operand))
      result.is_a?(BigDecimal) ? result.to_f : result
    end

    class InputIterator
      include Enumerable

      def initialize(input)
        @input = if input.is_a?(Array)
          input.flatten
        elsif input.is_a?(Hash)
          [input]
        elsif input.is_a?(Enumerable)
          input
        else
          Array(input)
        end
      end

      def join(glue)
        to_a.join(glue)
      end

      def reverse
        reverse_each.to_a
      end

      def each
        @input.each do |e|
          yield(e.respond_to?(:to_liquid) ? e.to_liquid : e)
        end
      end
    end
  end

  Template.register_filter(StandardFilters)
end
