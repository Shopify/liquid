# frozen_string_literal: true

module Liquid
  class Tokenizer
    attr_reader :line_number, :for_liquid_tag

    def initialize(
      source:,
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
      @tokens = if @for_liquid_tag
        @source.split("\n")
      else
        scan(@source)
      end

      @source = nil
    end

    # @param source [String]
    # @return [Array<String>]
    def scan(source)
      raise SyntaxError, "Invalid byte sequence in #{source.encoding}" unless source.valid_encoding?

      tokens = [] # : Array[String]
      pos = 0
      eos = source.bytesize

      # rubocop:disable Metrics/BlockNesting
      while pos < eos
        byte = source.getbyte(pos)
        next_byte = source.getbyte(pos + 1)

        if byte == 123 && next_byte == 123 # {{
          if (index = source.byteindex("}", pos + 2))
            if source.getbyte(index + 1) == 125 # }}
              tokens << source.byteslice(pos, index + 2 - pos)
              pos = index + 2
            else # } or %}
              tokens << source.byteslice(pos, index + 1 - pos)
              pos = index + 1
            end
          else
            tokens << "{{"
            pos += 2
          end
        elsif byte == 123 && next_byte == 37 # {%
          if (index = source.byteindex("%}", pos + 2))
            tokens << source.byteslice(pos, index + 2 - pos)
            pos = index + 2
          else
            tokens << "{%"
            pos += 2
          end
        else
          # Not markup. Scan until but not including {{ or {%
          index = source.byteindex("{", pos)

          unless index
            # No more markup. Scan until end of string.
            tokens << source.byteslice(pos, eos - pos)
            break
          end

          next_byte = source.getbyte(index + 1)

          while next_byte != 37 && next_byte != 123
            index = source.byteindex("{", index + 1)
            break unless index

            next_byte = source.getbyte(index + 1)
            unless next_byte
              index = nil
              break
            end
          end

          if index
            tokens << source.byteslice(pos, index - pos)
            pos = index
          else
            # No more markup. Scan until end of string.
            tokens << source.byteslice(pos, eos - pos)
            break
          end
        end
      end
      # rubocop:enable Metrics/BlockNesting

      tokens
    end
  end
end
