# frozen_string_literal: true

require "strscan"

module Liquid
  # Single-pass forward-only scanner for Liquid parsing.
  # Wraps StringScanner with higher-level methods for common Liquid constructs.
  # One Cursor per template parse — threaded through all parsing code.
  class Cursor
    # Byte constants
    SPACE   = 32
    TAB     = 9
    NL      = 10
    CR      = 13
    FF      = 12
    DASH    = 45  # '-'
    DOT     = 46  # '.'
    COLON   = 58  # ':'
    PIPE    = 124 # '|'
    QUOTE_S = 39  # "'"
    QUOTE_D = 34  # '"'
    LBRACK  = 91  # '['
    RBRACK  = 93  # ']'
    LPAREN  = 40  # '('
    RPAREN  = 41  # ')'
    QMARK   = 63  # '?'
    HASH    = 35  # '#'
    USCORE  = 95  # '_'
    COMMA   = 44
    ZERO    = 48
    NINE    = 57
    PCT     = 37  # '%'
    LCURLY  = 123 # '{'
    RCURLY  = 125 # '}'

    attr_reader :ss

    def initialize(source)
      @source = source
      @ss = StringScanner.new(source)
    end

    # ── Position ────────────────────────────────────────────────────
    def pos = @ss.pos

    def pos=(n)
      @ss.pos = n
    end

    def eos? = @ss.eos?
    def peek_byte = @ss.peek_byte
    def scan_byte = @ss.scan_byte

    # Reset scanner to a new string (for reuse on sub-markup)
    def reset(source)
      @source = source
      @ss.string = source
    end

    # Extract a slice from the source (deferred allocation)
    def slice(start, len)
      @source.byteslice(start, len)
    end

    # ── Whitespace ──────────────────────────────────────────────────
    # Skip spaces/tabs/newlines/cr, return count of newlines skipped
    def skip_ws
      nl = 0
      while (b = @ss.peek_byte)
        case b
        when SPACE, TAB, CR, FF then @ss.scan_byte
        when NL then @ss.scan_byte
                     nl += 1
        else break
        end
      end
      nl
    end

    # Check if remaining bytes are all whitespace
    def rest_blank?
      p = @ss.pos
      len = @source.bytesize
      while p < len
        b = @source.getbyte(p)
        return false unless b == SPACE || b == TAB || b == NL || b == CR || b == FF

        p += 1
      end
      true
    end

    # Regex for identifier: [a-zA-Z_][\w-]*\??
    ID_REGEX = /[a-zA-Z_][\w-]*\??/

    # ── Identifiers ─────────────────────────────────────────────────
    # Skip an identifier without allocating a string. Returns length skipped, or 0.
    def skip_id
      @ss.skip(ID_REGEX) || 0
    end

    # Check if next id matches expected string, consume if so. No allocation.
    def expect_id(expected)
      start = @ss.pos
      if @ss.skip(ID_REGEX) == expected.bytesize
        match = true
        expected.bytesize.times do |i|
          if @source.getbyte(start + i) != expected.getbyte(i)
            match = false
            break
          end
        end
        return true if match
      end
      @ss.pos = start
      false
    end

    # Scan a single identifier: [a-zA-Z_][\w-]*\??
    # Returns the string or nil if not at an identifier
    def scan_id
      @ss.scan(ID_REGEX)
    end

    # Scan a tag name: '#' or \w+
    def scan_tag_name
      if @ss.peek_byte == HASH
        @ss.scan_byte
        "#"
      else
        scan_id
      end
    end

    # ── Numbers ─────────────────────────────────────────────────────
    # Try to scan an integer or float. Returns the number or nil.
    def scan_number
      start = @ss.pos
      b = @ss.peek_byte
      return unless b

      if b == DASH
        @ss.scan_byte
        b = @ss.peek_byte
        unless b && b >= ZERO && b <= NINE
          @ss.pos = start
          return
        end
      elsif b >= ZERO && b <= NINE
        # ok
      else
        return
      end

      # Scan digits
      @ss.scan_byte
      @ss.scan_byte while (b = @ss.peek_byte) && b >= ZERO && b <= NINE

      if @ss.peek_byte == DOT
        @ss.scan_byte
        # Must have digit after dot for float
        if (b = @ss.peek_byte) && b >= ZERO && b <= NINE
          @ss.scan_byte
          @ss.scan_byte while (b = @ss.peek_byte) && b >= ZERO && b <= NINE
          return @source.byteslice(start, @ss.pos - start).to_f
        else
          # "123." — integer portion only, rewind past dot
          @ss.pos -= 1
        end
      end

      Integer(@source.byteslice(start, @ss.pos - start), 10)
    end

    # ── Strings ─────────────────────────────────────────────────────
    # Scan a quoted string ('...' or "..."). Returns the content without quotes, or nil.
    def scan_quoted_string
      b = @ss.peek_byte
      return unless b == QUOTE_S || b == QUOTE_D

      quote = b
      @ss.scan_byte
      start = @ss.pos
      @ss.scan_byte while (b = @ss.peek_byte) && b != quote
      content = @source.byteslice(start, @ss.pos - start)
      @ss.scan_byte if @ss.peek_byte == quote # consume closing quote
      content
    end

    # Scan a quoted string including quotes. Returns the full "..." or '...' string, or nil.
    def scan_quoted_string_raw
      b = @ss.peek_byte
      return unless b == QUOTE_S || b == QUOTE_D

      quote = b
      start = @ss.pos
      @ss.scan_byte
      @ss.scan_byte while (b = @ss.peek_byte) && b != quote
      @ss.scan_byte if @ss.peek_byte == quote
      @source.byteslice(start, @ss.pos - start)
    end

    # ── Expressions ─────────────────────────────────────────────────
    # Scan a simple variable lookup: name(.name)* — no brackets, no filters
    # Returns the string or nil
    def scan_dotted_id
      start = @ss.pos
      return unless scan_id

      while @ss.peek_byte == DOT
        @ss.scan_byte
        unless scan_id
          @ss.pos -= 1 # rewind the dot
          break
        end
      end
      @source.byteslice(start, @ss.pos - start)
    end

    # Skip a fragment without allocating. Returns length skipped, or 0.
    def skip_fragment
      b = @ss.peek_byte
      return 0 unless b

      start = @ss.pos
      if b == QUOTE_S || b == QUOTE_D
        quote = b
        @ss.scan_byte
        @ss.scan_byte while (b = @ss.peek_byte) && b != quote
        @ss.scan_byte if @ss.peek_byte == quote
      else
        while (b = @ss.peek_byte)
          break if b == SPACE || b == TAB || b == NL || b == CR || b == COMMA || b == PIPE

          @ss.scan_byte
        end
      end
      @ss.pos - start
    end

    # Scan a "QuotedFragment" — a quoted string or non-whitespace/comma/pipe run
    def scan_fragment
      b = @ss.peek_byte
      return unless b

      if b == QUOTE_S || b == QUOTE_D
        scan_quoted_string_raw
      else
        start = @ss.pos
        while (b = @ss.peek_byte)
          break if b == SPACE || b == TAB || b == NL || b == CR || b == COMMA || b == PIPE

          @ss.scan_byte
        end
        len = @ss.pos - start
        len > 0 ? @source.byteslice(start, len) : nil
      end
    end

    # ── Comparison operators ────────────────────────────────────────
    COMPARISON_OPS = {
      '==' => '==',
      '!=' => '!=',
      '<>' => '<>',
      '<=' => '<=',
      '>=' => '>=',
      '<' => '<',
      '>' => '>',
      'contains' => 'contains',
    }.freeze

    # Scan a comparison operator. Returns frozen string or nil.
    def scan_comparison_op
      start = @ss.pos
      b = @ss.peek_byte
      case b
      when 61, 33, 60, 62 # = ! < >
        @ss.scan_byte
        b2 = @ss.peek_byte
        if b2 == 61 || b2 == 62 # second char of ==, !=, <=, >=, <>
          @ss.scan_byte
        end
      when 99 # 'c' for contains
        id = scan_id
        return unless id == "contains"

        return COMPARISON_OPS['contains']
      else
        return
      end
      op_str = @source.byteslice(start, @ss.pos - start)
      COMPARISON_OPS[op_str] || (@ss.pos = start
                                 nil)
    end

    # ── Tag parsing helpers ─────────────────────────────────────────
    # Results from last parse_tag_token call (avoids array allocation)
    attr_reader :tag_markup, :tag_newlines

    # Parse the interior of a tag token: "{%[-] tag_name markup [-]%}"
    # Caller provides the full token string. Sets cursor to the token.
    # Returns tag_name string or nil. Sets tag_markup and tag_newlines.
    def parse_tag_token(token)
      reset(token)
      @ss.pos = 2 # skip "{%"
      @ss.scan_byte if peek_byte == DASH # skip whitespace control '-'
      nl = skip_ws
      tag_name = scan_tag_name
      return unless tag_name

      nl += skip_ws

      # markup is everything up to optional '-' before '%}'
      markup_end = token.bytesize - 2
      markup_end -= 1 if markup_end > @ss.pos && token.getbyte(markup_end - 1) == DASH
      @tag_markup = @ss.pos >= markup_end ? "" : token.byteslice(@ss.pos, markup_end - @ss.pos)
      @tag_newlines = nl

      tag_name
    end

    # Parse variable token interior: extract markup from "{{[-] ... [-]}}"
    def parse_variable_token(token)
      len = token.bytesize
      return if len < 4

      i = 2
      i = 3 if token.getbyte(i) == DASH
      parse_end = len - 3
      parse_end -= 1 if token.getbyte(parse_end) == DASH
      markup_len = parse_end - i + 1
      markup_len <= 0 ? "" : token.byteslice(i, markup_len)
    end

    # ── Simple condition parser ─────────────────────────────────────
    # Results from last parse_simple_condition call
    attr_reader :cond_left, :cond_op, :cond_right

    # Parse "expr [op expr]" from current position to end.
    # Returns true on success, nil on failure. Sets cond_left, cond_op, cond_right.
    def parse_simple_condition
      skip_ws
      @cond_left = scan_fragment
      return unless @cond_left

      skip_ws
      if eos?
        @cond_op = nil
        @cond_right = nil
        return true
      end

      @cond_op = scan_comparison_op
      return unless @cond_op

      skip_ws
      @cond_right = scan_fragment
      return unless @cond_right

      skip_ws
      return unless eos? # trailing junk

      true
    end
    # ── For tag parser ────────────────────────────────────────────────
    # Results from parse_for_markup
    attr_reader :for_var, :for_collection, :for_reversed

    # Parse "var in collection [reversed] [limit:N] [offset:N]"
    # Returns true on success, nil on failure.
    def parse_for_markup
      skip_ws
      @for_var = scan_id
      return unless @for_var

      skip_ws
      # expect "in"
      return unless scan_id == "in"

      skip_ws
      # Collection: parenthesized range or fragment
      if peek_byte == LPAREN
        start = @ss.pos
        depth = 1
        @ss.scan_byte
        while !@ss.eos? && depth > 0
          b = @ss.scan_byte
          depth += 1 if b == LPAREN
          depth -= 1 if b == RPAREN
        end
        @for_collection = @source.byteslice(start, @ss.pos - start)
      else
        @for_collection = scan_fragment
        return unless @for_collection
      end

      skip_ws
      # Check for 'reversed'
      saved = @ss.pos
      word = scan_id
      if word == "reversed"
        @for_reversed = true
      else
        @for_reversed = false
        @ss.pos = saved if word # rewind if we consumed a non-'reversed' word
      end

      true
    end
  end
end
