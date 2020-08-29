# frozen_string_literal: true

module Liquid
  class ResourceLimits
    attr_accessor :render_length_limit, :render_score_limit, :assign_score_limit
    attr_reader :render_score, :assign_score

    def initialize(limits)
      @render_length_limit = limits[:render_length_limit]
      @render_score_limit  = limits[:render_score_limit]
      @assign_score_limit  = limits[:assign_score_limit]
      reset
    end

    def increment_render_score(amount)
      @render_score += amount
      raise_limits_reached if @render_score_limit && @render_score > @render_score_limit
    end

    def increment_assign_score(amount)
      @assign_score += amount
      raise_limits_reached if @assign_score_limit && @assign_score > @assign_score_limit
    end

    def check_render_length(output_byte_size)
      raise_limits_reached if @render_length_limit && output_byte_size > @render_length_limit
    end

    def raise_limits_reached
      @reached_limit = true
      raise MemoryError, "Memory limits exceeded"
    end

    def reached?
      @reached_limit
    end

    def reset
      @reached_limit = false
      @render_score = @assign_score = 0
    end
  end
end
