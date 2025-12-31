# frozen_string_literal: true

# Liquid Compiled Template Runtime
#
# This module provides ALL helpers for compiled Liquid templates.
# It is loaded into the sandbox BEFORE lock!, so these methods
# are available to all compiled templates.
#
# Templates reference these as LR.method_name(args)
#
# == Security Note
#
# It is SAFE to expose side-effect-free, non-IO methods that don't leak
# objects with dangerous methods. For example:
#
#   - CGI.escapeHTML(str) -> returns a String (safe)
#   - Base64.strict_encode64(str) -> returns a String (safe)
#   - BigDecimal(str) -> returns a Numeric (safe)
#
# These are pure functions that take values and return values.
# They don't provide any capability to escape the sandbox.
#
# We capture METHOD REFERENCES (e.g., CGI.method(:escapeHTML)) before the
# sandbox locks. This means templates can use the functionality without
# having direct access to the CGI, Base64, or BigDecimal constants.
#
# Dependencies (CGI, Base64, BigDecimal) are loaded by box.rb into the
# sandbox BEFORE this file runs. The constants are preserved after lock.

module LR
  # === Type Conversion ===

  # Convert to string like Liquid does
  def self.to_s(obj)
    case obj
    when nil then ''
    when Array then obj.join
    else obj.to_s
    end
  end

  # Convert to number for arithmetic
  # Use Kernel.BigDecimal to access from root namespace
  def self.to_number(obj)
    case obj
    when Numeric then obj
    when String
      if obj.strip =~ /\A-?\d+\.\d+\z/
        Kernel.BigDecimal(obj)
      else
        obj.to_i
      end
    else 0
    end
  end

  # Convert to integer
  def self.to_integer(obj)
    return obj if obj.is_a?(Integer)
    Integer(obj.to_s) rescue 0
  end

  # === Truthiness ===

  # Liquid truthiness: only nil and false are falsy
  def self.truthy?(obj)
    obj != nil && obj != false
  end

  # === Output ===

  # Output a value, converting to string safely (handles arrays recursively)
  def self.output(obj)
    case obj
    when nil then ''
    when Array then obj.map { |o| output(o) }.join
    when BigDecimal
      # Format BigDecimal like Liquid does - avoid scientific notation
      obj.to_s('F')
    else obj.to_s
    end
  end

  # === Lookup ===

  # Variable lookup - handles hash/array access, method calls, to_liquid, and drop context
  def self.lookup(obj, key, context = nil)
    return nil if obj.nil?

    # Set context on Drops BEFORE accessing their methods
    obj = obj.to_liquid if obj.respond_to?(:to_liquid)
    obj.context = context if context && obj.respond_to?(:context=)

    # Perform the lookup
    result = if obj.respond_to?(:[]) && (obj.respond_to?(:key?) && obj.key?(key) || obj.respond_to?(:fetch) && key.is_a?(Integer))
      obj[key]
    elsif obj.respond_to?(key)
      obj.public_send(key)
    else
      nil
    end

    # Convert result to liquid and set context for nested Drops
    result = result.to_liquid if result.respond_to?(:to_liquid)
    result.context = context if context && result.respond_to?(:context=)
    result
  end

  # === HTML/URL Encoding ===
  # Capture method references before sandbox locks - only the specific methods we need
  CGI_ESCAPE_HTML = CGI.method(:escapeHTML)
  CGI_ESCAPE = CGI.method(:escape)
  CGI_UNESCAPE = CGI.method(:unescape)

  HTML_ESCAPE_MAP = { '&' => '&amp;', '<' => '&lt;', '>' => '&gt;', '"' => '&quot;', "'" => '&#39;' }.freeze

  def self.escape_html(obj)
    CGI_ESCAPE_HTML.call(to_s(obj))
  end

  def self.url_encode(obj)
    CGI_ESCAPE.call(to_s(obj))
  end

  def self.url_decode(obj)
    CGI_UNESCAPE.call(to_s(obj))
  end

  def self.escape_once(obj)
    # Only escape if not already escaped
    to_s(obj).gsub(/["><']|&(?!([a-zA-Z]+|(#\d+));)/, HTML_ESCAPE_MAP)
  end

  # === Base64 ===
  # Capture method references before sandbox locks
  BASE64_ENCODE = Base64.method(:strict_encode64)
  BASE64_DECODE = Base64.method(:strict_decode64)
  BASE64_URL_ENCODE = Base64.method(:urlsafe_encode64)
  BASE64_URL_DECODE = Base64.method(:urlsafe_decode64)

  def self.base64_encode(obj)
    BASE64_ENCODE.call(to_s(obj))
  end

  def self.base64_decode(obj)
    BASE64_DECODE.call(to_s(obj))
  end

  def self.base64_url_safe_encode(obj)
    BASE64_URL_ENCODE.call(to_s(obj))
  end

  def self.base64_url_safe_decode(obj)
    BASE64_URL_DECODE.call(to_s(obj))
  end

  # === String Manipulation ===

  def self.strip_html(obj)
    to_s(obj).gsub(%r{<script.*?</script>|<!--.*?-->|<style.*?</style>}m, '').gsub(/<.*?>/m, '')
  end

  # Truncate string to length with ellipsis
  def self.truncate(input, length = 50, ellipsis = '...')
    str = to_s(input)
    ell_str = to_s(ellipsis)
    len = length.to_i
    l = [len - ell_str.length, 0].max
    str.length > len ? str[0, l] + ell_str : str
  end

  # Truncate to word count
  def self.truncatewords(input, num_words = 15, ellipsis = '...')
    max_words = [num_words.to_i, 1].max
    words = to_s(input).split(' ', max_words + 1)
    if words.length > max_words
      words[0, max_words].join(' ') + to_s(ellipsis)
    else
      input.to_s
    end
  end

  # === Date Formatting ===

  def self.date(input, format)
    return input if format.to_s.empty?
    d = case input
    when Time, Date then input
    when 'now', 'today' then Time.now
    when /\A\d+\z/, Integer then Time.at(input.to_i)
    when String then (Time.parse(input) rescue input)
    else input
    end
    d.respond_to?(:strftime) ? d.strftime(format.to_s) : input
  end

  # === Collection Helpers ===

  # Iterate safely, handling ranges and non-iterables
  def self.iterate(collection)
    case collection
    when Range then collection.to_a
    when nil then []
    else collection.respond_to?(:each) ? collection : []
    end
  end

  # Get collection length safely
  def self.size(collection)
    collection.respond_to?(:size) ? collection.size : 0
  end

  # === Default Filter ===

  def self.default(input, default_value, allow_false: false)
    if allow_false
      (input.nil? || (input.respond_to?(:empty?) && input.empty?)) ? default_value : input
    else
      (!truthy?(input) || (input.respond_to?(:empty?) && input.empty?)) ? default_value : input
    end
  end

  # === Array/String Slice ===

  def self.slice(input, offset, length = 1)
    off = to_integer(offset)
    len = to_integer(length)
    if input.is_a?(Array)
      input.slice(off, len) || []
    else
      to_s(input).slice(off, len) || ''
    end
  end
end

# Alias for backwards compatibility
LiquidRuntime = LR
