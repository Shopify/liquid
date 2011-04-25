require 'strscan'

module Liquid
  # A custom subclass of StringScanner to help parse Liquid syntax.
  class Scanner < StringScanner

    def skip_opt_whitespace
      skip(/\s*/)
    end

    def require(pattern, error)
      scan(pattern) || raise(SyntaxError, error_message(error))
    end

    def error_message(error)
      location = rest.strip.length == 0 ? "at end of '#{string}'" : "in '#{rest}'"
      "#{error} #{location}"
    end

    def self.scan(string)
      scanner = new(string)
      yield scanner
    end
  end
end
