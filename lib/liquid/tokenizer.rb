# frozen_string_literal: true

require "strscan"

module Liquid
  class Tokenizer
    attr_reader :line_number, :for_liquid_tag

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
      @source = source.to_s.to_str
      @offset = 0
      @tokens = []

      tokenize if @source
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
      @ss = nil
    end

    # Fast tokenizer using String#index instead of StringScanner regex.
    # String#index is ~40% faster for finding { delimiters.
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

        if next_byte == PERCENTAGE # {%
          # Emit text before tag
          @tokens << src.byteslice(pos, idx - pos) if idx > pos

          # Find %} to close the tag
          close = src.byteindex('%}', idx + 2)
          if close
            @tokens << src.byteslice(idx, close + 2 - idx)
            pos = close + 2
          else
            @tokens << "{%"
            pos = idx + 2
          end
        elsif next_byte == OPEN_CURLEY # {{
          # Emit text before variable
          @tokens << src.byteslice(pos, idx - pos) if idx > pos

          # Scan variable token — matches original tokenizer's byte-by-byte logic:
          # Find } or {, then check next byte for }}/{% nesting
          scan_pos = idx + 2
          found = false
          while scan_pos < len
            b = src.getbyte(scan_pos)
            if b == CLOSE_CURLEY # }
              if scan_pos + 1 >= len
                # } at end of string — emit token up to here
                @tokens << src.byteslice(idx, scan_pos + 1 - idx)
                pos = scan_pos + 1
                found = true
                break
              end
              b2 = src.getbyte(scan_pos + 1)
              if b2 == CLOSE_CURLEY
                # Found }} — close variable
                @tokens << src.byteslice(idx, scan_pos + 2 - idx)
                pos = scan_pos + 2
                found = true
                break
              else
                # } followed by non-} — emit token up to here (matches original: @ss.pos -= 1)
                @tokens << src.byteslice(idx, scan_pos + 1 - idx)
                pos = scan_pos + 1
                found = true
                break
              end
            elsif b == OPEN_CURLEY
              if scan_pos + 1 < len && src.getbyte(scan_pos + 1) == PERCENTAGE
                # Found {% inside {{ — scan to %} and emit as one token
                close = src.byteindex('%}', scan_pos + 2)
                if close
                  @tokens << src.byteslice(idx, close + 2 - idx)
                  pos = close + 2
                else
                  @tokens << src.byteslice(idx, len - idx)
                  pos = len
                end
                found = true
                break
              end
              scan_pos += 1
            else
              scan_pos += 1
            end
          end

          unless found
            @tokens << "{{"
            pos = idx + 2
          end
        else
          # { followed by something else — it's text
          # Keep scanning from after this {
          # Find next { that could be {%  or {{
          next_open = idx + 1
          while next_open < len
            ni = src.byteindex('{', next_open)
            unless ni
              @tokens << src.byteslice(pos, len - pos)
              pos = len
              break
            end
            nb = ni + 1 < len ? src.getbyte(ni + 1) : nil
            if nb == PERCENTAGE || nb == OPEN_CURLEY
              @tokens << src.byteslice(pos, ni - pos)
              pos = ni
              break
            end
            next_open = ni + 1
          end
        end
      end
    end
  end
end
