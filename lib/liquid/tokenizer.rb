# frozen_string_literal: true

module Liquid
  class Tokenizer
    attr_reader :line_number, :for_liquid_tag

    def initialize(source, line_numbers = false, line_number: nil, for_liquid_tag: false)
      @source         = source
      @line_number    = line_number || (line_numbers ? 1 : nil)
      @for_liquid_tag = for_liquid_tag
      @offset = 0
      @state = :outside
      @ss = StringScanner.new(source)
    end

    def shift
      return nil if @ss.eos?

      token = take_new_next

      until @state == :outside || @ss.eos?
        token << if @state == :inside_variable || @state == :inside_tag
          take_inside
        else
          take_rest
        end
      end

      token
    end

    private

    def take_rest
      token = @ss.rest
      @ss.terminate
      @state = :outside
      token
    end

    def take_new_next
      start_pos = @ss.pos

      if (n = @ss.skip_until(VariableStart))
        if n == 2
          @state = :inside_variable
          end_pos = @ss.pos
        token = @source.byteslice(start_pos, end_pos - start_pos)
        else
          @ss.pos -= 2
          token = @source.byteslice(start_pos, n - 2)
        end

        @line_number += @for_liquid_tag ? 1 : token.count("\n") if @line_number
        token
      elsif (n = @ss.skip_until(TagStart))
        if n == 2
          @state = :inside_tag
          end_pos = @ss.pos
          token = @source.byteslice(start_pos, end_pos - start_pos)
        else
          @ss.pos -= 2
          token = @source.byteslice(start_pos, n - 2)
        end

        @line_number += @for_liquid_tag ? 1 : token.count("\n") if @line_number
        token
      else
        take_rest
      end
    end

    def take_inside
      start_pos = @ss.pos

      if @state == :inside_variable
        if (n = @ss.skip_until(VariableEnd))
          @state = :outside
          token = @source.byteslice(start_pos, n)
          @line_number += @for_liquid_tag ? 1 : token.count("\n") if @line_number
          token
        end
      elsif @state == :inside_tag
        if (n = @ss.skip_until(TagEnd))
          @state = :outside
          token = @source.byteslice(start_pos, n)
          @line_number += @for_liquid_tag ? 1 : token.count("\n") if @line_number
          token
        end
      else
        raise SyntaxError, "Unknown state: #{@state}"
      end
    end
  end
end
