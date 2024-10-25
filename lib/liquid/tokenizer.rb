# frozen_string_literal: true

require "strscan"

module Liquid
  class Tokenizer
    attr_reader :line_number, :for_liquid_tag

    TAG_END = /%\}/
    TAG_OR_VARIABLE_START = /\{[\{\%}]/
    NEWLINE = /\n/

    OPEN_CURLEY = "{".ord
    CLOSE_CURLEY = "}".ord
    PERCENTAGE = "%".ord

    def initialize(source, line_numbers = false, line_number: nil, for_liquid_tag: false)
      @line_number    = line_number || (line_numbers ? 1 : nil)
      @for_liquid_tag = for_liquid_tag
      @source         = source
      @ss             = StringScanner.new(source)
    end

    def shift
      return if @ss.eos?

      token = @for_liquid_tag ? next_liquid_token : next_token

      return nil unless token

      if @line_number
        @line_number += @for_liquid_tag ? 1 : token.count("\n")
      end

      token
    end

    private

    def next_liquid_token
      # read until we find a \n
      start = @ss.pos
      if @ss.skip_until(NEWLINE).nil?
        token = @ss.rest
        @ss.terminate
        return token
      end

      @source.byteslice(start, @ss.pos - start - 1)
    end

    def next_token
      # possible states: :text, :tag, :variable
      byte_a = @ss.peek_byte

      if byte_a == OPEN_CURLEY
        @ss.scan_byte

        byte_b = @ss.peek_byte

        if byte_b == PERCENTAGE
          @ss.scan_byte
          return next_tag_token
        elsif byte_b == OPEN_CURLEY
          @ss.scan_byte
          return next_variable_token
        end

        @ss.pos -= 1
      end

      next_text_token
    end

    def next_text_token
      start = @ss.pos

      unless @ss.skip_until(TAG_OR_VARIABLE_START)
        token = @ss.rest
        @ss.terminate
        return token
      end

      pos = @ss.pos -= 2
      @source.byteslice(start, pos - start)
    end

    def next_variable_token
      start = @ss.pos - 2

      # it is possible to see a {% before a }} so we need to check for that
      byte_a = @ss.scan_byte
      byte_b = byte_a

      while byte_b
        byte_a = @ss.scan_byte while byte_a && byte_a != CLOSE_CURLEY && byte_a != OPEN_CURLEY

        break unless byte_a

        byte_b = @ss.scan_byte

        if byte_b != CLOSE_CURLEY && byte_b != PERCENTAGE
          byte_a = byte_b
          next
        end

        if byte_a == CLOSE_CURLEY && byte_b == CLOSE_CURLEY
          return @source.byteslice(start, @ss.pos - start)
        elsif byte_a == OPEN_CURLEY && byte_b == PERCENTAGE
          return next_tag_token_with_start(start)
        end
      end

      "{{"
    end

    def next_tag_token
      start = @ss.pos - 2
      if (len = @ss.skip_until(TAG_END))
        @source.byteslice(start, len + 2)
      else
        "{%"
      end
    end

    def next_tag_token_with_start(start)
      @ss.skip_until(TAG_END)
      @source.byteslice(start, @ss.pos - start)
    end
  end
end
