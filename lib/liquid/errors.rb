module Liquid
  class Error < ::StandardError
    attr_accessor :line_number
    attr_accessor :markup_context

    def to_s(with_prefix=true)
      str = ""
      str << message_prefix if with_prefix
      str << super()

      if markup_context
        str << " "
        str << markup_context
      end

      str
    end

    def set_line_number_from_token(token)
      return unless token.respond_to?(:line_number)
      return if self.line_number
      self.line_number = token.line_number
    end

    def self.render(e)
      if e.is_a?(Liquid::Error)
        e.to_s
      else
        "Liquid error: #{e.to_s}"
      end
    end

    private

    def message_prefix
      str = ""
      if is_a?(SyntaxError)
        str << "Liquid syntax error"
      else
        str << "Liquid error"
      end

      if line_number
        str << " (line #{line_number})"
      end

      str << ": "
      str
    end
  end

  class ArgumentError < Error; end
  class ContextError < Error; end
  class FileSystemError < Error; end
  class StandardError < Error; end
  class SyntaxError < Error; end
  class StackLevelError < Error; end
  class TaintedError < Error; end
  class MemoryError < Error; end
end
