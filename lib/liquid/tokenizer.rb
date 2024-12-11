# frozen_string_literal: true

require "strscan"

module Liquid
  class Tokenizer1
    attr_reader :line_number, :for_liquid_tag

    def initialize(
      source:,
      string_scanner:, # this is not used
      line_numbers: false,
      line_number: nil,
      for_liquid_tag: false
    )
      @source         = source
      @line_number    = line_number || (line_numbers ? 1 : nil)
      @for_liquid_tag = for_liquid_tag
      @offset         = 0
      @tokens         = tokenize
    end

    def shift
      token = @tokens[@offset]
      return nil unless token

      @offset += 1

      if @line_number
        @line_number += @for_liquid_tag ? 1 : token.count("\n")
      end

      token
    end

    private

    def tokenize
      return [] if @source.empty?

      return @source.split("\n") if @for_liquid_tag

      tokens = @source.split(TemplateParser)

      # removes the rogue empty element at the beginning of the array
      if tokens[0]&.empty?
        @offset += 1
      end

      tokens
    end
  end

  class Tokenizer2
    attr_reader :line_number, :for_liquid_tag

    TAG_END = /%\}/
    TAG_OR_VARIABLE_START = /\{[\{\%]/
    NEWLINE = /\n/

    OPEN_CURLEY = "{".ord
    CLOSE_CURLEY = "}".ord
    PERCENTAGE = "%".ord

    def initialize(
      source:,
      string_scanner:,
      line_numbers: false,
      line_number: nil,
      for_liquid_tag: false
    )
      @line_number = line_number || (line_numbers ? 1 : nil)
      @for_liquid_tag = for_liquid_tag
      @source = source
      @offset = 0
      @tokens = []

      @ss = string_scanner
      @ss.string = @source

      tokenize
    end

    def shift
      token = @tokens[@offset]

      return unless token

      @offset += 1

      if @line_number
        @line_number += @for_liquid_tag ? 1 : token.count("\n")
      end

      token
    end

    private

    def tokenize
      if @for_liquid_tag
        @tokens = @source.split("\n")
      else
        @tokens << shift_normal until @ss.eos?
      end

      @source = nil
      @ss = nil
    end

    def shift_normal
      token = next_token

      return unless token

      token
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

      byte_a = byte_b = @ss.scan_byte

      while byte_b
        byte_a = @ss.scan_byte while byte_a && (byte_a != CLOSE_CURLEY && byte_a != OPEN_CURLEY)

        break unless byte_a

        if @ss.eos?
          return byte_a == CLOSE_CURLEY ? @source.byteslice(start, @ss.pos - start) : "{{"
        end

        byte_b = @ss.scan_byte

        if byte_a == CLOSE_CURLEY
          if byte_b == CLOSE_CURLEY
            return @source.byteslice(start, @ss.pos - start)
          elsif byte_b != CLOSE_CURLEY
            @ss.pos -= 1
            return @source.byteslice(start, @ss.pos - start)
          end
        elsif byte_a == OPEN_CURLEY && byte_b == PERCENTAGE
          return next_tag_token_with_start(start)
        end

        byte_a = byte_b
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

  # Remove this once we can depend on strscan >= 3.1.1
  Tokenizer = StringScanner.instance_methods.include?(:scan_byte) ? Tokenizer2 : Tokenizer1
end
