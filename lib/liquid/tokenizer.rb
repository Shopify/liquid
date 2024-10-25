# frozen_string_literal: true

require "strscan"

module Liquid
  class Tokenizer
    attr_reader :line_number, :for_liquid_tag

    TAG_END = /%\}/
    TAG_OR_VARIABLE_START = /\{[\{\%}]/
    NEWLINE = /\n/

    OPEN_CURLEY = 123
    CLOSE_CURLEY = 125
    PERCENTAGE = 37

    def initialize(source, line_numbers = false, line_number: nil, for_liquid_tag: false)
      @line_number = line_number || (line_numbers ? 1 : nil)

      @for_liquid_tag = for_liquid_tag
      @tokens = []
      tokenize(source)
    end

    private def tokenize(source)
      ss = StringScanner.new(source)

      while token = t_shift(ss)
        @tokens.push(token)
      end
    end

    def shift
      token = @tokens.shift

      return nil unless token

      if @line_number
        @line_number += @for_liquid_tag ? 1 : token.count("\n")
      end

      token
    end

    private def t_shift(ss)
      return nil if ss.eos?

      @for_liquid_tag ? next_liquid_token(ss) : next_token(ss)
    end

    private

    def next_liquid_token(ss)
      # read until we find a \n
      start = ss.pos
      if ss.scan_until(NEWLINE).nil?
        token = ss.rest
        ss.terminate
        return token
      end

      ss.string.byteslice(start, ss.pos - start - 1)
    end

    def next_token(ss)
      if ss.pos == 0
        if ss.string.start_with?("{{")
          ss.pos = 2
          return next_variable_token(ss)
        elsif ss.string.start_with?("{%")
          ss.pos = 2
          return next_tag_token(ss)
        else
          return next_text_token(ss)
        end
      end

      # possible states: :text, :tag, :variable
      byte_a = ss.scan_byte

      if byte_a == OPEN_CURLEY
        byte_b = ss.scan_byte

        if byte_b == PERCENTAGE
          return next_tag_token(ss)
        elsif byte_b == OPEN_CURLEY
          return next_variable_token(ss)
        end

        ss.pos -= 1
      end

      ss.pos -= 1
      next_text_token(ss)
    end

    def next_text_token(ss)
      start = ss.pos

      unless ss.skip_until(TAG_OR_VARIABLE_START)
        token = ss.rest
        ss.terminate
        return token
      end

      ss.pos -= 2
      ss.string.byteslice(start, ss.pos - start)
    end

    def next_variable_token(ss)
      start = ss.pos - 2

      # it is possible to see a {% before a }} so we need to check for that
      byte_a = ss.scan_byte

      until ss.eos?
        while ss.eos? == false && byte_a != CLOSE_CURLEY && byte_a != OPEN_CURLEY
          byte_a = ss.scan_byte
        end

        break if ss.eos?

        byte_b = ss.scan_byte

        if byte_b != CLOSE_CURLEY && byte_b != PERCENTAGE
          byte_a = byte_b
          next
        end

        if byte_a == CLOSE_CURLEY && byte_b == CLOSE_CURLEY
          return ss.string.byteslice(start, ss.pos - start)
        elsif byte_a == OPEN_CURLEY && byte_b == PERCENTAGE
          return next_tag_token(ss, start)
        end
      end

      return "{{"
    end

    def next_tag_token(ss, start = nil)
      start ||= ss.pos - 2

      ss.scan_until(TAG_END)

      ss.string.byteslice(start, ss.pos - start)
    end
  end
end
