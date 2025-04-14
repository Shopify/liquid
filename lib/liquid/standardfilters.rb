# frozen_string_literal: true

require 'cgi'
require 'base64'
require 'bigdecimal'
module Liquid
  module StandardFilters
    MAX_I32 = (1 << 31) - 1
    private_constant :MAX_I32

    MIN_I64 = -(1 << 63)
    MAX_I64 = (1 << 63) - 1
    I64_RANGE = MIN_I64..MAX_I64
    private_constant :MIN_I64, :MAX_I64, :I64_RANGE

    HTML_ESCAPE = {
      '&' => '&amp;',
      '>' => '&gt;',
      '<' => '&lt;',
      '"' => '&quot;',
      "'" => '&#39;',
    }.freeze
    HTML_ESCAPE_ONCE_REGEXP = /["><']|&(?!([a-zA-Z]+|(#\d+));)/
    STRIP_HTML_BLOCKS       = Regexp.union(
      %r{<script.*?</script>}m,
      /<!--.*?-->/m,
      %r{<style.*?</style>}m,
    )
    STRIP_HTML_TAGS = /<.*?>/m

    class << self
      def try_coerce_encoding(input, encoding:)
        original_encoding = input.encoding
        if input.encoding != encoding
          input.force_encoding(encoding)
          unless input.valid_encoding?
            input.force_encoding(original_encoding)
          end
        end
        input
      end
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Returns the size of a string or array.
    # @liquid_description
    #   The size of a string is the number of characters that the string includes. The size of an array is the number of items
    #   in the array.
    # @liquid_syntax variable | size
    # @liquid_return [number]
    def size(input)
      input.respond_to?(:size) ? input.size : 0
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Converts a string to all lowercase characters.
    # @liquid_syntax string | downcase
    # @liquid_return [string]
    def downcase(input)
      Utils.to_s(input).downcase
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Converts a string to all uppercase characters.
    # @liquid_syntax string | upcase
    # @liquid_return [string]
    def upcase(input)
      Utils.to_s(input).upcase
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Capitalizes the first word in a string and downcases the remaining characters.
    # @liquid_syntax string | capitalize
    # @liquid_return [string]
    def capitalize(input)
      Utils.to_s(input).capitalize
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Escapes special characters in HTML, such as `<>`, `'`, and `&`, and converts characters into escape sequences. The filter doesn't effect characters within the string that don’t have a corresponding escape sequence.".
    # @liquid_syntax string | escape
    # @liquid_return [string]
    def escape(input)
      CGI.escapeHTML(Utils.to_s(input)) unless input.nil?
    end
    alias_method :h, :escape

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Escapes a string without changing characters that have already been escaped.
    # @liquid_syntax string | escape_once
    # @liquid_return [string]
    def escape_once(input)
      Utils.to_s(input).gsub(HTML_ESCAPE_ONCE_REGEXP, HTML_ESCAPE)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Converts any URL-unsafe characters in a string to the
    #   [percent-encoded](https://developer.mozilla.org/en-US/docs/Glossary/percent-encoding) equivalent.
    # @liquid_description
    #   > Note:
    #   > Spaces are converted to a `+` character, instead of a percent-encoded character.
    # @liquid_syntax string | url_encode
    # @liquid_return [string]
    def url_encode(input)
      CGI.escape(Utils.to_s(input)) unless input.nil?
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Decodes any [percent-encoded](https://developer.mozilla.org/en-US/docs/Glossary/percent-encoding) characters
    #   in a string.
    # @liquid_syntax string | url_decode
    # @liquid_return [string]
    def url_decode(input)
      return if input.nil?

      result = CGI.unescape(Utils.to_s(input))
      raise Liquid::ArgumentError, "invalid byte sequence in #{result.encoding}" unless result.valid_encoding?

      result
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Encodes a string to [Base64 format](https://developer.mozilla.org/en-US/docs/Glossary/Base64).
    # @liquid_syntax string | base64_encode
    # @liquid_return [string]
    def base64_encode(input)
      Base64.strict_encode64(Utils.to_s(input))
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Decodes a string in [Base64 format](https://developer.mozilla.org/en-US/docs/Glossary/Base64).
    # @liquid_syntax string | base64_decode
    # @liquid_return [string]
    def base64_decode(input)
      input = Utils.to_s(input)
      StandardFilters.try_coerce_encoding(Base64.strict_decode64(input), encoding: input.encoding)
    rescue ::ArgumentError
      raise Liquid::ArgumentError, "invalid base64 provided to base64_decode"
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Encodes a string to URL-safe [Base64 format](https://developer.mozilla.org/en-US/docs/Glossary/Base64).
    # @liquid_syntax string | base64_url_safe_encode
    # @liquid_return [string]
    def base64_url_safe_encode(input)
      Base64.urlsafe_encode64(Utils.to_s(input))
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Decodes a string in URL-safe [Base64 format](https://developer.mozilla.org/en-US/docs/Glossary/Base64).
    # @liquid_syntax string | base64_url_safe_decode
    # @liquid_return [string]
    def base64_url_safe_decode(input)
      input = Utils.to_s(input)
      StandardFilters.try_coerce_encoding(Base64.urlsafe_decode64(input), encoding: input.encoding)
    rescue ::ArgumentError
      raise Liquid::ArgumentError, "invalid base64 provided to base64_url_safe_decode"
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Returns a substring or series of array items, starting at a given 0-based index.
    # @liquid_description
    #   By default, the substring has a length of one character, and the array series has one array item. However, you can
    #   provide a second parameter to specify the number of characters or array items.
    # @liquid_syntax string | slice
    # @liquid_return [string]
    def slice(input, offset, length = nil)
      offset = Utils.to_integer(offset)
      length = length ? Utils.to_integer(length) : 1

      begin
        if input.is_a?(Array)
          input.slice(offset, length) || []
        else
          Utils.to_s(input).slice(offset, length) || ''
        end
      rescue RangeError
        if I64_RANGE.cover?(length) && I64_RANGE.cover?(offset)
          raise # unexpected error
        end
        offset = offset.clamp(I64_RANGE)
        length = length.clamp(I64_RANGE)
        retry
      end
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Truncates a string down to a given number of characters.
    # @liquid_description
    #   If the specified number of characters is less than the length of the string, then an ellipsis (`...`) is appended to
    #   the truncated string. The ellipsis is included in the character count of the truncated string.
    # @liquid_syntax string | truncate: number
    # @liquid_return [string]
    def truncate(input, length = 50, truncate_string = "...")
      return if input.nil?
      input_str = Utils.to_s(input)
      length    = Utils.to_integer(length)

      truncate_string_str = Utils.to_s(truncate_string)

      l = length - truncate_string_str.length
      l = 0 if l < 0

      input_str.length > length ? input_str[0...l].concat(truncate_string_str) : input_str
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Truncates a string down to a given number of words.
    # @liquid_description
    #   If the specified number of words is less than the number of words in the string, then an ellipsis (`...`) is appended to
    #   the truncated string.
    #
    #   > Caution:
    #   > HTML tags are treated as words, so you should strip any HTML from truncated content. If you don't strip HTML, then
    #   > closing HTML tags can be removed, which can result in unexpected behavior.
    # @liquid_syntax string | truncatewords: number
    # @liquid_return [string]
    def truncatewords(input, words = 15, truncate_string = "...")
      return if input.nil?
      input = Utils.to_s(input)
      words = Utils.to_integer(words)
      words = 1 if words <= 0

      wordlist = begin
        input.split(" ", words + 1)
      rescue RangeError
        # integer too big for String#split, but we can semantically assume no truncation is needed
        return input if words + 1 > MAX_I32
        raise # unexpected error
      end
      return input if wordlist.length <= words

      wordlist.pop
      truncate_string = Utils.to_s(truncate_string)
      wordlist.join(" ").concat(truncate_string)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Splits a string into an array of substrings based on a given separator.
    # @liquid_syntax string | split: string
    # @liquid_return [array[string]]
    def split(input, pattern)
      pattern = Utils.to_s(pattern)
      input = Utils.to_s(input)
      input.split(pattern)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Strips all whitespace from the left and right of a string.
    # @liquid_syntax string | strip
    # @liquid_return [string]
    def strip(input)
      input = Utils.to_s(input)
      input.strip
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Strips all whitespace from the left of a string.
    # @liquid_syntax string | lstrip
    # @liquid_return [string]
    def lstrip(input)
      input = Utils.to_s(input)
      input.lstrip
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Strips all whitespace from the right of a string.
    # @liquid_syntax string | rstrip
    # @liquid_return [string]
    def rstrip(input)
      input = Utils.to_s(input)
      input.rstrip
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Strips all HTML tags from a string.
    # @liquid_syntax string | strip_html
    # @liquid_return [string]
    def strip_html(input)
      input = Utils.to_s(input)
      empty  = ''
      result = input.gsub(STRIP_HTML_BLOCKS, empty)
      result.gsub!(STRIP_HTML_TAGS, empty)
      result
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Strips all newline characters (line breaks) from a string.
    # @liquid_syntax string | strip_newlines
    # @liquid_return [string]
    def strip_newlines(input)
      input = Utils.to_s(input)
      input.gsub(/\r?\n/, '')
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Combines all of the items in an array into a single string, separated by a space.
    # @liquid_syntax array | join
    # @liquid_return [string]
    def join(input, glue = ' ')
      glue = Utils.to_s(glue)
      InputIterator.new(input, context).join(glue)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Sorts the items in an array in case-sensitive alphabetical, or numerical, order.
    # @liquid_syntax array | sort
    # @liquid_return [array[untyped]]
    def sort(input, property = nil)
      ary = InputIterator.new(input, context)

      return [] if ary.empty?

      if property.nil?
        ary.sort do |a, b|
          nil_safe_compare(a, b)
        end
      elsif ary.all? { |el| el.respond_to?(:[]) }
        begin
          ary.sort { |a, b| nil_safe_compare(a[property], b[property]) }
        rescue TypeError
          raise_property_error(property)
        end
      end
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Sorts the items in an array in case-insensitive alphabetical order.
    # @liquid_description
    #   > Caution:
    #   > You shouldn't use the `sort_natural` filter to sort numerical values. When comparing items an array, each item is converted to a
    #   > string, so sorting on numerical values can lead to unexpected results.
    # @liquid_syntax array | sort_natural
    # @liquid_return [array[untyped]]
    def sort_natural(input, property = nil)
      ary = InputIterator.new(input, context)

      return [] if ary.empty?

      if property.nil?
        ary.sort do |a, b|
          nil_safe_casecmp(a, b)
        end
      elsif ary.all? { |el| el.respond_to?(:[]) }
        begin
          ary.sort { |a, b| nil_safe_casecmp(a[property], b[property]) }
        rescue TypeError
          raise_property_error(property)
        end
      end
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Filters an array to include only items with a specific property value.
    # @liquid_description
    #   This requires you to provide both the property name and the associated value.
    # @liquid_syntax array | where: string, string
    # @liquid_return [array[untyped]]
    def where(input, property, target_value = nil)
      filter_array(input, property, target_value) { |ary, &block| ary.select(&block) }
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Filters an array to exclude items with a specific property value.
    # @liquid_description
    #   This requires you to provide both the property name and the associated value.
    # @liquid_syntax array | reject: string, string
    # @liquid_return [array[untyped]]
    def reject(input, property, target_value = nil)
      filter_array(input, property, target_value) { |ary, &block| ary.reject(&block) }
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Tests if any item in an array has a specific property value.
    # @liquid_description
    #   This requires you to provide both the property name and the associated value.
    # @liquid_syntax array | has: string, string
    # @liquid_return [boolean]
    def has(input, property, target_value = nil)
      filter_array(input, property, target_value, false) { |ary, &block| ary.any?(&block) }
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Returns the first item in an array with a specific property value.
    # @liquid_description
    #   This requires you to provide both the property name and the associated value.
    # @liquid_syntax array | find: string, string
    # @liquid_return [untyped]
    def find(input, property, target_value = nil)
      filter_array(input, property, target_value, nil) { |ary, &block| ary.find(&block) }
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Returns the index of the first item in an array with a specific property value.
    # @liquid_description
    #   This requires you to provide both the property name and the associated value.
    # @liquid_syntax array | find_index: string, string
    # @liquid_return [number]
    def find_index(input, property, target_value = nil)
      filter_array(input, property, target_value, nil) { |ary, &block| ary.find_index(&block) }
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Removes any duplicate items in an array.
    # @liquid_syntax array | uniq
    # @liquid_return [array[untyped]]
    def uniq(input, property = nil)
      ary = InputIterator.new(input, context)

      if property.nil?
        ary.uniq
      elsif ary.empty? # The next two cases assume a non-empty array.
        []
      else
        ary.uniq do |item|
          item[property]
        rescue TypeError
          raise_property_error(property)
        rescue NoMethodError
          return nil unless item.respond_to?(:[])
          raise
        end
      end
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Reverses the order of the items in an array.
    # @liquid_syntax array | reverse
    # @liquid_return [array[untyped]]
    def reverse(input)
      ary = InputIterator.new(input, context)
      ary.reverse
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Creates an array of values from a specific property of the items in an array.
    # @liquid_syntax array | map: string
    # @liquid_return [array[untyped]]
    def map(input, property)
      InputIterator.new(input, context).map do |e|
        e = e.call if e.is_a?(Proc)

        if property == "to_liquid"
          e
        elsif e.respond_to?(:[])
          r = e[property]
          r.is_a?(Proc) ? r.call : r
        end
      end
    rescue TypeError
      raise_property_error(property)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Removes any `nil` items from an array.
    # @liquid_syntax array | compact
    # @liquid_return [array[untyped]]
    def compact(input, property = nil)
      ary = InputIterator.new(input, context)

      if property.nil?
        ary.compact
      elsif ary.empty? # The next two cases assume a non-empty array.
        []
      else
        ary.reject do |item|
          item[property].nil?
        rescue TypeError
          raise_property_error(property)
        rescue NoMethodError
          return nil unless item.respond_to?(:[])
          raise
        end
      end
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Replaces any instance of a substring inside a string with a given string.
    # @liquid_syntax string | replace: string, string
    # @liquid_return [string]
    def replace(input, string, replacement = '')
      string = Utils.to_s(string)
      replacement = Utils.to_s(replacement)
      input = Utils.to_s(input)
      input.gsub(string, replacement)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Replaces the first instance of a substring inside a string with a given string.
    # @liquid_syntax string | replace_first: string, string
    # @liquid_return [string]
    def replace_first(input, string, replacement = '')
      string = Utils.to_s(string)
      replacement = Utils.to_s(replacement)
      input = Utils.to_s(input)
      input.sub(string, replacement)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Replaces the last instance of a substring inside a string with a given string.
    # @liquid_syntax string | replace_last: string, string
    # @liquid_return [string]
    def replace_last(input, string, replacement)
      input = Utils.to_s(input)
      string = Utils.to_s(string)
      replacement = Utils.to_s(replacement)

      start_index = input.rindex(string)

      return input unless start_index

      output = input.dup
      output[start_index, string.length] = replacement
      output
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Removes any instance of a substring inside a string.
    # @liquid_syntax string | remove: string
    # @liquid_return [string]
    def remove(input, string)
      replace(input, string, '')
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Removes the first instance of a substring inside a string.
    # @liquid_syntax string | remove_first: string
    # @liquid_return [string]
    def remove_first(input, string)
      replace_first(input, string, '')
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Removes the last instance of a substring inside a string.
    # @liquid_syntax string | remove_last: string
    # @liquid_return [string]
    def remove_last(input, string)
      replace_last(input, string, '')
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Adds a given string to the end of a string.
    # @liquid_syntax string | append: string
    # @liquid_return [string]
    def append(input, string)
      input = Utils.to_s(input)
      string = Utils.to_s(string)
      input + string
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Concatenates (combines) two arrays.
    # @liquid_description
    #   > Note:
    #   > The `concat` filter won't filter out duplicates. If you want to remove duplicates, then you need to use the
    #   > [`uniq` filter](/docs/api/liquid/filters/uniq).
    # @liquid_syntax array | concat: array
    # @liquid_return [array[untyped]]
    def concat(input, array)
      unless array.respond_to?(:to_ary)
        raise ArgumentError, "concat filter requires an array argument"
      end
      InputIterator.new(input, context).concat(array)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Adds a given string to the beginning of a string.
    # @liquid_syntax string | prepend: string
    # @liquid_return [string]
    def prepend(input, string)
      input = Utils.to_s(input)
      string = Utils.to_s(string)
      string + input
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Converts newlines (`\n`) in a string to HTML line breaks (`<br>`).
    # @liquid_syntax string | newline_to_br
    # @liquid_return [string]
    def newline_to_br(input)
      input = Utils.to_s(input)
      input.gsub(/\r?\n/, "<br />\n")
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category date
    # @liquid_summary
    #   Formats a date according to a specified format string.
    # @liquid_description
    #   This filter formats a date using various format specifiers. If the format string is empty,
    #   the original input is returned. If the input cannot be converted to a date, the original input is returned.
    #
    #   The following format specifiers can be used:
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
    # @liquid_syntax date | date: string
    # @liquid_return [string]
    def date(input, format)
      str_format = Utils.to_s(format)
      return input if str_format.empty?

      return input unless (date = Utils.to_date(input))

      date.strftime(str_format)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Returns the first item in an array.
    # @liquid_syntax array | first
    # @liquid_return [untyped]
    def first(array)
      array.first if array.respond_to?(:first)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Returns the last item in an array.
    # @liquid_syntax array | last
    # @liquid_return [untyped]
    def last(array)
      array.last if array.respond_to?(:last)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category math
    # @liquid_summary
    #   Returns the absolute value of a number.
    # @liquid_syntax number | abs
    # @liquid_return [number]
    def abs(input)
      result = Utils.to_number(input).abs
      result.is_a?(BigDecimal) ? result.to_f : result
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category math
    # @liquid_summary
    #   Adds two numbers.
    # @liquid_syntax number | plus: number
    # @liquid_return [number]
    def plus(input, operand)
      apply_operation(input, operand, :+)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category math
    # @liquid_summary
    #   Subtracts a given number from another number.
    # @liquid_syntax number | minus: number
    # @liquid_return [number]
    def minus(input, operand)
      apply_operation(input, operand, :-)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category math
    # @liquid_summary
    #   Multiplies a number by a given number.
    # @liquid_syntax number | times: number
    # @liquid_return [number]
    def times(input, operand)
      apply_operation(input, operand, :*)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category math
    # @liquid_summary
    #   Divides a number by a given number. The `divided_by` filter produces a result of the same type as the divisor. This means if you divide by an integer, the result will be an integer, and if you divide by a float, the result will be a float.
    # @liquid_syntax number | divided_by: number
    # @liquid_return [number]
    def divided_by(input, operand)
      apply_operation(input, operand, :/)
    rescue ::ZeroDivisionError => e
      raise Liquid::ZeroDivisionError, e.message
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category math
    # @liquid_summary
    #   Returns the remainder of dividing a number by a given number.
    # @liquid_syntax number | modulo: number
    # @liquid_return [number]
    def modulo(input, operand)
      apply_operation(input, operand, :%)
    rescue ::ZeroDivisionError => e
      raise Liquid::ZeroDivisionError, e.message
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category math
    # @liquid_summary
    #   Rounds a number to the nearest integer.
    # @liquid_syntax number | round
    # @liquid_return [number]
    def round(input, n = 0)
      result = Utils.to_number(input).round(Utils.to_number(n))
      result = result.to_f if result.is_a?(BigDecimal)
      result = result.to_i if n == 0
      result
    rescue ::FloatDomainError => e
      raise Liquid::FloatDomainError, e.message
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category math
    # @liquid_summary
    #   Rounds a number up to the nearest integer.
    # @liquid_syntax number | ceil
    # @liquid_return [number]
    def ceil(input)
      Utils.to_number(input).ceil.to_i
    rescue ::FloatDomainError => e
      raise Liquid::FloatDomainError, e.message
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category math
    # @liquid_summary
    #   Rounds a number down to the nearest integer.
    # @liquid_syntax number | floor
    # @liquid_return [number]
    def floor(input)
      Utils.to_number(input).floor.to_i
    rescue ::FloatDomainError => e
      raise Liquid::FloatDomainError, e.message
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category math
    # @liquid_summary
    #   Limits a number to a minimum value.
    # @liquid_syntax number | at_least
    # @liquid_return [number]
    def at_least(input, n)
      min_value = Utils.to_number(n)

      result = Utils.to_number(input)
      result = min_value if min_value > result
      result.is_a?(BigDecimal) ? result.to_f : result
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category math
    # @liquid_summary
    #   Limits a number to a maximum value.
    # @liquid_syntax number | at_most
    # @liquid_return [number]
    def at_most(input, n)
      max_value = Utils.to_number(n)

      result = Utils.to_number(input)
      result = max_value if max_value < result
      result.is_a?(BigDecimal) ? result.to_f : result
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category default
    # @liquid_summary
    #   Sets a default value for any variable whose value is one of the following:
    #
    #   - [`empty`](/docs/api/liquid/basics#empty)
    #   - [`false`](/docs/api/liquid/basics#truthy-and-falsy)
    #   - [`nil`](/docs/api/liquid/basics#nil)
    # @liquid_syntax variable | default: variable
    # @liquid_return [untyped]
    # @liquid_optional_param allow_false: [boolean] Whether to use false values instead of the default.
    def default(input, default_value = '', options = {})
      options = {} unless options.is_a?(Hash)
      false_check = options['allow_false'] ? input.nil? : !Liquid::Utils.to_liquid_value(input)
      false_check || (input.respond_to?(:empty?) && input.empty?) ? default_value : input
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Returns the sum of all elements in an array.
    # @liquid_syntax array | sum
    # @liquid_return [number]
    def sum(input, property = nil)
      ary = InputIterator.new(input, context)
      return 0 if ary.empty?

      values_for_sum = ary.map do |item|
        if property.nil?
          item
        elsif item.respond_to?(:[])
          item[property]
        else
          0
        end
      rescue TypeError
        raise_property_error(property)
      end

      result = InputIterator.new(values_for_sum, context).sum do |item|
        Utils.to_number(item)
      end

      result.is_a?(BigDecimal) ? result.to_f : result
    end

    private

    attr_reader :context

    def filter_array(input, property, target_value, default_value = [], &block)
      ary = InputIterator.new(input, context)

      return default_value if ary.empty?

      block.call(ary) do |item|
        if target_value.nil?
          item[property]
        else
          item[property] == target_value
        end
      rescue TypeError
        raise_property_error(property)
      rescue NoMethodError
        return nil unless item.respond_to?(:[])
        raise
      end
    end

    def raise_property_error(property)
      raise Liquid::ArgumentError, "cannot select the property '#{Utils.to_s(property)}'"
    end

    def apply_operation(input, operand, operation)
      result = Utils.to_number(input).send(operation, Utils.to_number(operand))
      result.is_a?(BigDecimal) ? result.to_f : result
    end

    def nil_safe_compare(a, b)
      result = a <=> b

      if result
        result
      elsif a.nil?
        1
      elsif b.nil?
        -1
      else
        raise Liquid::ArgumentError, "cannot sort values of incompatible types"
      end
    end

    def nil_safe_casecmp(a, b)
      if !a.nil? && !b.nil?
        a.to_s.casecmp(b.to_s)
      elsif a.nil? && b.nil?
        0
      else
        a.nil? ? 1 : -1
      end
    end

    class InputIterator
      include Enumerable

      def initialize(input, context)
        @context = context
        @input   = if input.is_a?(Array)
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
        first = true
        output = +""
        each do |item|
          if first
            first = false
          else
            output << glue
          end

          output << Liquid::Utils.to_s(item)
        end
        output
      end

      def concat(args)
        to_a.concat(args)
      end

      def reverse
        reverse_each.to_a
      end

      def uniq(&block)
        to_a.uniq do |item|
          item = Utils.to_liquid_value(item)
          block ? yield(item) : item
        end
      end

      def compact
        to_a.compact
      end

      def empty?
        @input.each { return false }
        true
      end

      def each
        @input.each do |e|
          e = e.respond_to?(:to_liquid) ? e.to_liquid : e
          e.context = @context if e.respond_to?(:context=)
          yield(e)
        end
      end
    end
  end
end
