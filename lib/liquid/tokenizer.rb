# frozen_string_literal: true

require "strscan"

module Liquid
  class Tokenizer
    attr_reader :line_number, :for_liquid_tag

    TAG_END = /%\}/
    TAG_OR_VARIABLE_START = /\{[\{\%]/
    NEWLINE = /\n/
    OPEN_CURLEY = "{".ord
    CLOSE_CURLEY = "}".ord
    PERCENTAGE = "%".ord
    EMPTY_MATCH_MAP = [].freeze

    def initialize(
      source:,
      string_scanner:,
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
        @ss = string_scanner
        @ss.string = @source
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

    def peek
      @tokens[@offset]
    end

    def position
      [@offset, @line_number]
    end

    def position=(pos)
      @offset, @line_number = pos
    end

    def matching_end_tag?(tag_name)
      precompute_end_tag_matches unless @has_matching_end_tag
      @has_matching_end_tag[@offset - 1]
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

    # Precomputes which token positions have a matching depth-0 end tag.
    #
    # Uses a two-phase approach to avoid unnecessary work:
    #
    # 1. A cheap byte-level scan checks whether any end tag
    #    exists at all. If none is found, assigns
    #    +EMPTY_MATCH_MAP+ and returns immediately with zero
    #    allocations.
    #
    # 2. A full stack-based bracket matching pass runs only
    #    when phase 1 finds at least one end tag.
    #
    # This method is called lazily on the first invocation
    # of #matching_end_tag?.
    #
    def precompute_end_tag_matches
      if @tokens.length - @offset < 1
        @has_matching_end_tag = EMPTY_MATCH_MAP
        return
      end

      # Phase 1: Check if ANY end tag exists in the remaining tokens.
      has_any_end_tag = false
      i = @offset
      while i < @tokens.length
        token = @tokens[i]
        i += 1
        next unless token.start_with?("{%")

        j = 2
        j += 1 if token.getbyte(j) == 45   # '-'
        j += 1 while token.getbyte(j) == 32 # ' '

        if token.getbyte(j) == 101 &&     # 'e'
           token.getbyte(j + 1) == 110 && # 'n'
           token.getbyte(j + 2) == 100    # 'd'
          has_any_end_tag = true
          break
        end
      end

      unless has_any_end_tag
        @has_matching_end_tag = EMPTY_MATCH_MAP
        return
      end

      # Phase 2: Full stack-based bracket matching (existing logic).
      @has_matching_end_tag = Array.new(@tokens.length, false)
      open_stacks = Hash.new { |h, k| h[k] = [] }

      @tokens.each_with_index do |token, idx|
        next unless token.start_with?("{%")

        # Advance past "{%", optional "-", and spaces to reach tag name
        j = 2
        j += 1 if token.getbyte(j) == 45   # '-'
        j += 1 while token.getbyte(j) == 32 # ' '

        # Extract tag name: scan word characters [a-zA-Z0-9_]
        name_start = j
        byte = token.getbyte(j)
        while byte && ((byte >= 97 && byte <= 122) || # a-z
                       (byte >= 65 && byte <= 90) ||  # A-Z
                       (byte >= 48 && byte <= 57) ||  # 0-9
                       byte == 95)                     # _
          j += 1
          byte = token.getbyte(j)
        end
        next if j == name_start  # no tag name found

        name = token.byteslice(name_start, j - name_start)

        if name.start_with?("end")
          base = name.byteslice(3, name.bytesize - 3)
          stack = open_stacks[base]
          if stack.length > 0
            open_pos = stack.pop
            @has_matching_end_tag[open_pos] = true
          end
        else
          open_stacks[name] << idx
        end
      end
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
    rescue ::ArgumentError => e
      if e.message == "invalid byte sequence in #{@ss.string.encoding}"
        raise SyntaxError, "Invalid byte sequence in #{@ss.string.encoding}"
      else
        raise
      end
    end

    def next_variable_token
      start = @ss.pos - 2

      byte_a = byte_b = @ss.scan_byte

      while byte_b
        byte_a = @ss.scan_byte while byte_a && byte_a != CLOSE_CURLEY && byte_a != OPEN_CURLEY

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
end
