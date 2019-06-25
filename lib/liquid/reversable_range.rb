module Liquid
  class ReversableRange
    include Enumerable

    def initialize(min, max)
      @min = min
      @max = max
      @reversed = false
    end

    def each
      if reversed
        index = max
        while index >= min
          yield index
          index -= 1
        end
      else
        index = min
        while index <= max
          yield index
          index += 1
        end
      end
    end

    def reverse!
      @reversed = !reversed
      self
    end

    def empty?
      max < min
    end

    def size
      difference = max - min
      if difference > 0
        difference + 1
      else
        0
      end
    end

    def load_slice(from, to = nil)
      to ||= max
      slice_max = [max, to].min
      slice_min = [min, from].max
      range = ReversableRange.new(slice_min, slice_max)
      range.reverse! if reversed
      range
    end

    def ==(other)
      other.is_a?(self.class) &&
        other.min == min &&
        other.max == max &&
        other.reversed == reversed
    end

    def to_s
      if reversed
        "#{max}..#{min}"
      else
        "#{min}..#{max}"
      end
    end

    def to_liquid
      self
    end

    protected

    attr_reader :min, :max, :reversed
  end
end
