module Liquid
  class Error < ::StandardError
    attr_accessor :line_number

    def self.render(e)
      str = ""

      if e.is_a?(SyntaxError)
        str << "Liquid syntax error"
      else
        str << "Liquid error"
      end

      if e.respond_to?(:line_number) && e.line_number
        str << " (line #{e.line_number})"
      end

      str << ": "
      str << e.message
      str
    end

    def self.error_from_token(e, token)
      e.set_line_number_from_token(token) if e.is_a?(Liquid::Error)
      e
    end

    def set_line_number_from_token(token)
      return unless token.respond_to?(:line_number)
      self.line_number = token.line_number
    end
  end

  class ArgumentError < Error; end
  class ContextError < Error; end
  class FilterNotFound < Error; end
  class FileSystemError < Error; end
  class StandardError < Error; end
  class SyntaxError < Error; end
  class StackLevelError < Error; end
  class MemoryError < Error; end
end
