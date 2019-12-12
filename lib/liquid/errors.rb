# frozen_string_literal: true

module Liquid
  class Error < ::StandardError
    attr_accessor :line_number
    attr_accessor :template_name
    attr_accessor :markup_context

    def to_s(with_prefix = true)
      str = +""
      str << message_prefix if with_prefix
      str << super()

      if markup_context
        str << " "
        str << markup_context
      end

      str
    end

    private

    def message_prefix
      str = +""
      str <<
        if is_a?(SyntaxError)
          "Liquid syntax error"
        elsif is_a?(MemoryError)
          "Liquid memory limit error"
        else
          "Liquid error"
        end

      if line_number
        str << " ("
        str << template_name << " " if template_name
        str << "line " << line_number.to_s << ")"
      end

      str << ": "
      str
    end
  end

  class MemoryError < Error
    RENDER_LENGTH_ERROR_MESSAGE = 'Too many bytes rendered.'
    RENDER_SCORE_ERROR_MESSAGE = 'Too many tags rendered.'
    ASSIGN_SCORE_ERROR_MESSAGE = 'Too many bytes assigned to variables.'
  end

  ArgumentError       = Class.new(Error)
  ContextError        = Class.new(Error)
  FileSystemError     = Class.new(Error)
  StandardError       = Class.new(Error)
  SyntaxError         = Class.new(Error)
  StackLevelError     = Class.new(Error)
  TaintedError        = Class.new(Error)
  ZeroDivisionError   = Class.new(Error)
  FloatDomainError    = Class.new(Error)
  UndefinedVariable   = Class.new(Error)
  UndefinedDropMethod = Class.new(Error)
  UndefinedFilter     = Class.new(Error)
  MethodOverrideError = Class.new(Error)
  InternalError       = Class.new(Error)
end
