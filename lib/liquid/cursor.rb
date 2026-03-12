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
      saved = @ss.pos
      @ss.skip(/\s*/)
      result = @ss.eos?
      @ss.pos = saved
      result
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
      len = @ss.skip(ID_REGEX)
      if len == expected.bytesize
        # Compare bytes directly without allocating a string
        i = 0
        while i < len
          unless @source.getbyte(start + i) == expected.getbyte(i)
            @ss.pos = start
            return false
          end
          i += 1
        end
        return true
      end
      @ss.pos = start if len
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

    # Regex for numbers: -?\d+(\.\d+)?
    FLOAT_REGEX = /-?\d+\.\d+/
    INT_REGEX = /-?\d+/

    # ── Numbers ─────────────────────────────────────────────────────
    # Try to scan an integer or float. Returns the number or nil.
    def scan_number
      if (s = @ss.scan(FLOAT_REGEX))
        s.to_f
      elsif (s = @ss.scan(INT_REGEX))
        s.to_i
      end
    end

    # Regex for quoted string content (without quotes)
    SINGLE_QUOTED_CONTENT = /'([^']*)'/
    DOUBLE_QUOTED_CONTENT = /"([^"]*)"/

    # ── Strings ─────────────────────────────────────────────────────
    # Scan a quoted string ('...' or "..."). Returns the content without quotes, or nil.
    def scan_quoted_string
      if @ss.scan(SINGLE_QUOTED_CONTENT) || @ss.scan(DOUBLE_QUOTED_CONTENT)
        @ss[1]
      end
    end

    # Regex for quoted strings (single or double quoted, including quotes)
    QUOTED_STRING_RAW = /"[^"]*"|'[^']*'/

    # Scan a quoted string including quotes. Returns the full "..." or '...' string, or nil.
    def scan_quoted_string_raw
      @ss.scan(QUOTED_STRING_RAW)
    end

    # Regex for dotted identifier: name(.name)*
    DOTTED_ID_REGEX = /[a-zA-Z_][\w-]*\??(?:\.[a-zA-Z_][\w-]*\??)*/

    # ── Expressions ─────────────────────────────────────────────────
    # Scan a simple variable lookup: name(.name)* — no brackets, no filters
    # Returns the string or nil
    def scan_dotted_id
      @ss.scan(DOTTED_ID_REGEX)
    end

    # Skip a fragment without allocating. Returns length skipped, or 0.
    def skip_fragment
      @ss.skip(QUOTED_STRING_RAW) || @ss.skip(UNQUOTED_FRAGMENT) || 0
    end

    # Regex for unquoted fragment: non-whitespace/comma/pipe sequence
    UNQUOTED_FRAGMENT = /[^\s,|]+/

    # Scan a "QuotedFragment" — a quoted string or non-whitespace/comma/pipe run
    def scan_fragment
      @ss.scan(QUOTED_STRING_RAW) || @ss.scan(UNQUOTED_FRAGMENT)
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
    # Regex for comparison operators
    COMPARISON_OP_REGEX = /==|!=|<>|<=|>=|<|>|contains(?!\w)/

    def scan_comparison_op
      if (op = @ss.scan(COMPARISON_OP_REGEX))
        COMPARISON_OPS[op]
      end
    end

    # ── Tag parsing helpers ─────────────────────────────────────────
    # Results from last parse_tag_token call (avoids array allocation)
    attr_reader :tag_markup, :tag_newlines

    # Parse the interior of a tag token: "{%[-] tag_name markup [-]%}"
    # Pure byte operations — avoids StringScanner reset overhead.
    # Returns tag_name string or nil. Sets tag_markup and tag_newlines.
    def parse_tag_token(token)
      len = token.bytesize
      pos = 2 # skip "{%"
      pos += 1 if token.getbyte(pos) == DASH # skip '-'
      nl = 0

      # Skip whitespace, count newlines
      while pos < len
        b = token.getbyte(pos)
        case b
        when SPACE, TAB, CR, FF then pos += 1
        when NL then pos += 1; nl += 1
        else break
        end
      end

      # Scan tag name: '#' or [a-zA-Z_][\w-]*
      name_start = pos
      b = token.getbyte(pos)
      if b == HASH
        pos += 1
      elsif b && ((b >= 97 && b <= 122) || (b >= 65 && b <= 90) || b == USCORE)
        pos += 1
        while pos < len
          b = token.getbyte(pos)
          break unless (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || (b >= 48 && b <= 57) || b == USCORE || b == DASH
          pos += 1
        end
        pos += 1 if pos < len && token.getbyte(pos) == QMARK
      else
        return
      end
      tag_name = token.byteslice(name_start, pos - name_start)

      # Skip whitespace after tag name, count newlines
      while pos < len
        b = token.getbyte(pos)
        case b
        when SPACE, TAB, CR, FF then pos += 1
        when NL then pos += 1; nl += 1
        else break
        end
      end

      # markup is everything up to optional '-' before '%}'
      markup_end = len - 2
      markup_end -= 1 if markup_end > pos && token.getbyte(markup_end - 1) == DASH
      @tag_markup = pos >= markup_end ? "" : token.byteslice(pos, markup_end - pos)
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
