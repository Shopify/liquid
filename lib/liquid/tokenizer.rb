# frozen_string_literal: true

require "strscan"

module Liquid
  class Tokenizer
    attr_reader :line_number, :for_liquid_tag

    TAG_START = /\{%/
    TAG_END = /%\}/
    VARIABLE_START = /\{\{/
    VARIABLE_END = /\}\}/
    TAG_OR_VARIABLE_START = /\{[\{\%}]/

    def initialize(source, line_numbers = false, line_number: nil, for_liquid_tag: false)
      @source         = source
      @line_number    = line_number || (line_numbers ? 1 : nil)
      @for_liquid_tag = for_liquid_tag
      @offset         = 0
      @ss = StringScanner.new(source)
    end

    def shift
      return nil if @ss.eos?

      token = @for_liquid_tag ? next_liquid_token : next_token

      return nil unless token

      @offset += 1

      if @line_number
        @line_number += @for_liquid_tag ? 1 : token.count("\n")
      end

      token
    end

    private

    def next_liquid_token
      # read until we find a \n
      start = @ss.pos
      if @ss.scan_until(/\n/).nil?
        token = @ss.rest
        @ss.terminate
        return token
      end

      @ss.string.byteslice(start, @ss.pos - start - 1)
    end

    def next_token
      # possible states: :text, :tag, :variable
      c_list = @ss.peek(2)

      case c_list
      when "{%"
        next_tag_token
      when "{{"
        next_variable_token
      else
        next_text_token
      end
    end

    def next_text_token
      start = @ss.pos

      if @ss.scan_until(TAG_OR_VARIABLE_START).nil?
        token = @ss.rest
        @ss.terminate
        return token
      end

      @ss.pos -= 2

      @ss.string.byteslice(start, @ss.pos - start)
    end

    def next_variable_token
      start = @ss.pos
      @ss.pos += 2
      found_variable_end = false

      # it is possible to see a {% before a }} so we need to check for that
      until @ss.eos?
        case @ss.peek(2)
        when "}}"
          @ss.pos += 2
          found_variable_end = true
          break
        when "{%"
          return next_tag_token(start)
        end

        @ss.pos += 1
      end

      return "{{" unless found_variable_end

      @ss.string.byteslice(start, @ss.pos - start)
    end

    def next_tag_token(start = nil)
      start = @ss.pos if start.nil?
      @ss.pos += 2

      if @ss.scan_until(TAG_END).nil?
        raise_syntax_error("tag was not properly terminated")
      end

      @ss.string.byteslice(start, @ss.pos - start)
    end

    def raise_syntax_error(message)
      raise SyntaxError, message
    end
  end
end
