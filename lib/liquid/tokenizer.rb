# frozen_string_literal: true

module Liquid
  class Tokenizer
    attr_reader :line_number, :for_liquid_tag

    def initialize(
      source:,
      string_scanner: nil,
      line_numbers: false,
      line_number: nil,
      for_liquid_tag: false
    )
      @line_number = line_number || (line_numbers ? 1 : nil)
      @for_liquid_tag = for_liquid_tag
      @source = source.to_s
      @offset = 0
      @tokens = []

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
        tokenize_fast
      end

      @source = nil
    end

    # Fast tokenizer using String#byteindex instead of StringScanner regex.
    # String#byteindex is ~40% faster for finding { delimiters.
    def tokenize_fast
      src = @source
      unless src.valid_encoding?
        raise SyntaxError, "Invalid byte sequence in #{src.encoding}"
      end

      len = src.bytesize
      pos = 0

      while pos < len
        # Find next { which could start a tag or variable
        idx = src.byteindex('{', pos)

        unless idx
          # No more tags/variables — rest is text
          @tokens << src.byteslice(pos, len - pos) if pos < len
          break
        end

        next_byte = idx + 1 < len ? src.getbyte(idx + 1) : nil

        if next_byte == Cursor::PCT # {%
          # Emit text before tag
          @tokens << src.byteslice(pos, idx - pos) if idx > pos

          # Find %} to close the tag
          close = src.byteindex('%}', idx + 2)
          if close
            @tokens << src.byteslice(idx, close + 2 - idx)
            pos = close + 2
          else
            # Emit malformed token to propagate a missing-terminator error in the parser
            @tokens << "{%"
            pos = idx + 2
          end
        elsif next_byte == Cursor::LCURLY # {{
          # Emit text before variable, then scan for the closing }}.
          @tokens << src.byteslice(pos, idx - pos) if idx > pos
          pos = scan_variable_token(src, idx, len)
        else
          # Lone '{' — not the start of a tag or variable.
          # Find the next '{{' or '{%' to know where this text token ends.
          # Using two byteindex calls avoids a nested loop and is always O(n).
          tag_start = src.byteindex('{%', idx + 1)
          var_start = src.byteindex('{{', idx + 1)
          next_token = [tag_start, var_start].compact.min
          if next_token
            @tokens << src.byteslice(pos, next_token - pos)
            pos = next_token
          else
            @tokens << src.byteslice(pos, len - pos)
            pos = len
          end
        end
      end
    end

    # Scans a {{ ... }} variable token starting at `idx` in `src`.
    # Emits the token to @tokens and returns the new position after the token.
    # Handles }}, single }, and embedded {% ... %} (nested tag inside variable).
    private def scan_variable_token(src, idx, len)
      # Byte-by-byte scan: find } or {, then inspect the next byte.
      scan_pos = idx + 2
      while scan_pos < len
        b = src.getbyte(scan_pos)
        if b == Cursor::RCURLY # }
          if scan_pos + 1 >= len
            # } at end of string — emit token up to here
            @tokens << src.byteslice(idx, scan_pos + 1 - idx)
            return scan_pos + 1
          end
          b2 = src.getbyte(scan_pos + 1)
          if b2 == Cursor::RCURLY
            # Found }} — close variable
            @tokens << src.byteslice(idx, scan_pos + 2 - idx)
            return scan_pos + 2
          else
            # } followed by non-} — emit token up to here (matches original: @ss.pos -= 1)
            @tokens << src.byteslice(idx, scan_pos + 1 - idx)
            return scan_pos + 1
          end
        elsif b == Cursor::LCURLY && scan_pos + 1 < len && src.getbyte(scan_pos + 1) == Cursor::PCT
          # Found {% inside {{ — scan to %} and emit as one token
          close = src.byteindex('%}', scan_pos + 2)
          if close
            @tokens << src.byteslice(idx, close + 2 - idx)
            return close + 2
          else
            @tokens << src.byteslice(idx, len - idx)
            return len
          end
        else
          scan_pos += 1
        end
      end

      # Reached end without finding }} — malformed
      @tokens << "{{"
      idx + 2
    end
  end
end
