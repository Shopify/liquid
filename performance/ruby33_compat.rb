# frozen_string_literal: true

# Compatibility shim for Ruby 3.3
# The Liquid library uses peek_byte and scan_byte which are only available in Ruby 3.4+

require 'strscan'

unless StringScanner.method_defined?(:peek_byte)
  class StringScanner
    def peek_byte
      return nil if eos?
      string.getbyte(pos)
    end
  end
end

unless StringScanner.method_defined?(:scan_byte)
  class StringScanner
    def scan_byte
      return nil if eos?
      byte = string.getbyte(pos)
      self.pos += 1
      byte
    end
  end
end
