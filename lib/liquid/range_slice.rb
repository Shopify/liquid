# frozen_string_literal: true

module Liquid
  class RangeSlice
    attr_reader :length

    def initialize(range, from, to, resource_limits)
      range_length = range.end - range.begin
      range_length += 1 unless range.exclude_end?
      range_length = 0 if range_length.negative?

      start = [from, 0].max
      finish = [to || range_length, range_length].min

      @first = range.begin + start
      @length = [finish - start, 0].max
      @direction = 1
      @resource_limits = resource_limits
    end

    def empty?
      @length.zero?
    end

    def each
      return enum_for(:each) unless block_given?

      value = @first
      @length.times do
        @resource_limits.increment_render_score(1)
        yield value
        value += @direction
      end
    end

    def reverse!
      unless empty?
        @first += @direction * (@length - 1)
        @direction = -@direction
      end
      self
    end
  end
end
