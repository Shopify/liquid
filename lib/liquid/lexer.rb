# frozen_string_literal: true

module Liquid
  class StringScanner
    def initialize(string)
      @len = string.length
      @string = string.freeze
      @buffer = IO::Buffer.for(@string)
      @pos    = 0
    end

    def eos?
      @pos >= @len
    end

    def peek(n = 0)
      return if @pos + n >= @len
      @buffer.get_value(:U8, @pos + n)
    end

    def match(str)
      return if @pos + str.length > @len

      if (@buffer.slice(@pos, str.length) <=> IO::Buffer.for(str)) == 0
        advance(str.length)
      end
    end

    def match_until(char)
      pos = 1
      pos += 1 while peek(pos) != char
      if peek(pos) == char
        advance(pos + 1)
      end
    end

    def advance(n = 1)
      original_pos = @pos
      @pos += n
      @string[original_pos, n]
    end

    def space?(c)
      return false unless c
      c == 32 || c == 9 || c == 10 || c == 13
    end

    def skip_spaces
      @pos += 1 while @pos < @len && space?(@buffer.get_value(:U8, @pos))
    end
  end

  class Lexer
    SPECIALS = {
      '|'.ord => :pipe,
      '.'.ord => :dot,
      ':'.ord => :colon,
      ','.ord => :comma,
      '['.ord => :open_square,
      ']'.ord => :close_square,
      '('.ord => :open_round,
      ')'.ord => :close_round,
      '?'.ord => :question,
      '-'.ord => :dash,
    }.freeze

    LESS_THAN = '<'.ord
    GREATER_THAN = '>'.ord
    EQUALS = '='.ord
    EXCLAMATION = '!'.ord
    QUOTE = '"'.ord
    APOSTROPHE = "'".ord
    DASH = '-'.ord
    DOT = '.'.ord
    UNDERSCORE = '_'.ord
    QUESTION_MARK = '?'.ord

    def initialize(input)
      @ss = StringScanner.new(input)
    end

    def digit?(char)
      return false unless char
      char >= 48 && char <= 57
    end

    def alpha?(char)
      return false unless char
      char >= 65 && char <= 90 || char >= 97 && char <= 122
    end

    def identifier?(char)
      return false unless char
      digit?(char) || alpha?(char) || char == UNDERSCORE || char == DASH
    end

    def tokenize
      @output = []

      until @ss.eos?
        @ss.skip_spaces
        break if @ss.eos?

        next_char = @ss.peek
        case next_char
        when LESS_THAN
          @output << [:comparison, @ss.match("<=") || @ss.match("<>") || @ss.match("<")]
          next
        when GREATER_THAN
          @output << [:comparison, @ss.match(">=") || @ss.match(">")]
          next
        when EQUALS
          if (match = @ss.match("=="))
            @output << [:comparison, match]
            next
          end
        when EXCLAMATION
          if (match = @ss.match("!="))
            @output << [:comparison, match]
            next
          end
        when DOT
          if (match = @ss.match(".."))
            @output << [:dotdot, match]
            next
          end
        end

        if (match = @ss.match("contains"))
          @output << [:comparison, match]
          next
        end

        if next_char == APOSTROPHE || next_char == QUOTE
          if (str = @ss.match_until(next_char))
            @output << [:string, str]
            next
          end
        end

        if next_char == DASH || digit?(next_char)
          peek = 1
          has_dot = false
          while (peeked = @ss.peek(peek))
            if !has_dot && peeked == DOT
              has_dot = true
            elsif !digit?(peeked)
              break
            end
            peek += 1
          end
          peek -= 1

          if @ss.peek(peek) == DOT
            peek -= 1
          end

          if @ss.peek(peek) != DASH
            @output << [:number, @ss.advance(peek)]
            next
          end
        end

        if alpha?(next_char) || next_char == UNDERSCORE
          peek = 1
          peek += 1 while identifier?(@ss.peek(peek))
          peek += 1 if @ss.peek(peek) == QUESTION_MARK
          @output << [:id, @ss.advance(peek)]
          next
        end

        if (special = SPECIALS[next_char])
          @output << [special, @ss.advance]
          next
        else
          raise SyntaxError, "Unexpected character #{next_char.chr}"
        end
      end

      @output << [:end_of_string]
    end
  end
end
