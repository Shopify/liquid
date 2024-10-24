# frozen_string_literal: true

module Liquid
  class Tokenizer
    attr_reader :line_number, :for_liquid_tag

    def initialize(source, line_numbers = false, line_number: nil, for_liquid_tag: false)
      @source         = source
      @line_number    = line_number || (line_numbers ? 1 : nil)
      @for_liquid_tag = for_liquid_tag
      @offset         = 0
      @state = :outside
      @ss = StringScanner.new(source)
      @n = 0
    end

    def shift
      @n += 1

      puts @ss.string if @n > 10000
      puts @ss.pos if @n > 10000
      return nil if @ss.eos?

      token = +""

      if (t = take_new_next)
        token << t
      end

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
      puts "take_rest: #{@state}"
      xtake_rest
    end

    def take_new_next
      puts "take_new_next: #{@state}"
      xtake_new_next
    end

    def take_inside
      puts "take_inside: #{@state}"
      xtake_inside
    end

    def xtake_rest
      token = @ss.rest
      @ss.terminate
      @state = :outside
      token
    end

    "{% foo %}"
    def xtake_new_next
      start_pos = @ss.pos

      if (n = @ss.skip_until(VariableStart))
        @state = :inside_variable unless n == 2
        end_pos = @ss.pos
        token = @source.byteslice(start_pos, end_pos - start_pos)
        @line_number += @for_liquid_tag ? 1 : token.count("\n") if @line_number
        token
      elsif (n = @ss.skip_until(TagStart))
        @state = :inside_tag unless n == 2
        end_pos = @ss.pos
        token = @source.byteslice(start_pos, end_pos - start_pos)
        @line_number += @for_liquid_tag ? 1 : token.count("\n") if @line_number
        token
      else
        take_rest
      end
    end

    def xtake_inside
      start_pos = @ss.pos
      if @state == :inside_variable
        if (n = @ss.skip_until(VariableEnd))
          @state = :outside
          token = @source.byteslice(start_pos, start_pos + n)
          @line_number += @for_liquid_tag ? 1 : token.count("\n") if @line_number
          token
        end
      elsif @state == :inside_tag
        if (n = @ss.skip_until(TagEnd))
          @state = :outside
          token = @source.byteslice(start_pos, start_pos + n)
          @line_number += @for_liquid_tag ? 1 : token.count("\n") if @line_number
          token
        end
      else
        raise SyntaxError, "Unknown state: #{@state}"
      end
    end
  end
end
