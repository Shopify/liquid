# frozen_string_literal: true

module Liquid
  class Tokenizer
    attr_reader :line_number, :for_liquid_tag

    TAG_END = /%\}/
    TAG_OR_VARIABLE_START = /\{[\{\%]/
    NEWLINE = /\n/

    OPEN_CURLEY = "{".ord
    CLOSE_CURLEY = "}".ord
    PERCENTAGE = "%".ord

    # In these encodings an ASCII byte is always an ASCII character, so a byte
    # search finds the same delimiters as a regular expression search.
    BYTE_SEARCH_ENCODINGS = [Encoding::UTF_8, Encoding::US_ASCII, Encoding::BINARY].freeze

    # `string_scanner:` is accepted for compatibility with callers written for
    # the StringScanner-based tokenizer. It is not used.
    def initialize(
      source:,
      string_scanner: nil,
      line_numbers: false,
      line_number: nil,
      for_liquid_tag: false
    )
      @line_number = line_number || (line_numbers ? 1 : nil)
      @for_liquid_tag = for_liquid_tag
      @source = source.to_s.to_str
      @offset = 0
      @tokens = []

      if @source
        tokenize
      end
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
        @byte_search = BYTE_SEARCH_ENCODINGS.include?(@source.encoding)
        @valid_encoding = @source.valid_encoding?
        @eos = @source.bytesize
        @pos = 0
        @tokens << next_token while @pos < @eos
      end

      @source = nil
    end

    def next_token
      # possible states: :text, :tag, :variable
      if @source.getbyte(@pos) == OPEN_CURLEY
        byte_b = @source.getbyte(@pos + 1)

        if byte_b == PERCENTAGE
          @pos += 2
          return next_tag_token
        elsif byte_b == OPEN_CURLEY
          @pos += 2
          return next_variable_token
        end
      end

      next_text_token
    end

    def next_text_token
      start = @pos

      if (index = tag_or_variable_start_index)
        @pos = index
        @source.byteslice(start, index - start)
      else
        @pos = @eos
        @source.byteslice(start, @eos - start)
      end
    rescue ::ArgumentError => e
      if e.message == "invalid byte sequence in #{@source.encoding}"
        raise SyntaxError, "Invalid byte sequence in #{@source.encoding}"
      else
        raise
      end
    end

    def tag_or_variable_start_index
      return regexp_index(TAG_OR_VARIABLE_START) unless @byte_search

      # A regular expression search raises ArgumentError for an invalid source, so a byte search does too.
      TAG_OR_VARIABLE_START.match?(@source) unless @valid_encoding

      index = @pos
      while (index = @source.byteindex("{", index))
        byte = @source.getbyte(index + 1)
        return index if byte == OPEN_CURLEY || byte == PERCENTAGE

        index += 1
      end
      nil
    end

    def next_variable_token
      start = @pos - 2
      pos = @pos

      # Each step reads one byte and advances past it, as a scanner does.
      byte_a = byte_b = @source.getbyte(pos)
      pos += 1 if byte_a

      while byte_b
        while byte_a && byte_a != CLOSE_CURLEY && byte_a != OPEN_CURLEY
          byte_a = @source.getbyte(pos)
          pos += 1 if byte_a
        end

        break unless byte_a

        if pos >= @eos
          @pos = pos
          return byte_a == CLOSE_CURLEY ? @source.byteslice(start, pos - start) : "{{"
        end

        byte_b = @source.getbyte(pos)
        pos += 1

        if byte_a == CLOSE_CURLEY
          pos -= 1 unless byte_b == CLOSE_CURLEY
          @pos = pos
          return @source.byteslice(start, pos - start)
        elsif byte_a == OPEN_CURLEY && byte_b == PERCENTAGE
          @pos = pos
          return next_tag_token_with_start(start)
        end

        byte_a = byte_b
      end

      @pos = pos
      "{{"
    end

    def next_tag_token
      start = @pos - 2

      if (index = tag_end_index)
        @pos = index + 2
        @source.byteslice(start, @pos - start)
      else
        "{%"
      end
    end

    def next_tag_token_with_start(start)
      if (index = tag_end_index)
        @pos = index + 2
      end

      @source.byteslice(start, @pos - start)
    end

    def tag_end_index
      return regexp_index(TAG_END) unless @byte_search

      # A regular expression search raises ArgumentError for an invalid source, so a byte search does too.
      TAG_END.match?(@source) unless @valid_encoding

      @source.byteindex("%}", @pos)
    end

    def regexp_index(pattern)
      # For an ASCII-incompatible source, a StringScanner search raised
      # Encoding::CompatibilityError at any offset, and byteindex raises
      # IndexError at an offset inside a character. A match raises the
      # StringScanner error.
      pattern.match?(@source) unless @source.encoding.ascii_compatible?

      @source.byteindex(pattern, @pos)
    end
  end
end
