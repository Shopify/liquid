module Liquid
  class Error < ::StandardError
    attr_accessor :line_number

    def self.render(e)
      msg = if e.is_a?(Liquid::Error) && e.line_number
        "#{e.line_number}: #{e.message}"
      else
        e.message
      end

      case e
      when SyntaxError
        "Liquid syntax error: #{msg}"
      else
        "Liquid error: #{msg}"
      end
    end

    def self.error_with_line_number(e, token)
      if e.is_a?(Liquid::Error)
        e.set_line_number_from_token(token)
      end

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
