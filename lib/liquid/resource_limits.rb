# frozen_string_literal: true

module Liquid
  class ResourceLimits < Struct.new(:render_length_limit, :render_score_limit, :assign_score_limit, :render_score, :assign_score, :last_capture_length, keyword_init: true)
    def increment_render_score(amount)
      self.render_score ||= 0
      self.render_score += amount
      raise_limits_reached if render_score_limit && render_score > render_score_limit
    end

    def increment_assign_score(amount)
      self.assign_score ||= 0
      self.assign_score += amount
      raise_limits_reached if assign_score_limit && assign_score > assign_score_limit
    end

    # update either render_length or assign_score based on whether or not the writes are captured
    def increment_write_score(output)
      if (last_captured = last_capture_length)
        captured = output.bytesize
        increment = captured - last_captured
        self.last_capture_length = captured
        increment_assign_score(increment)
      elsif render_length_limit && output.bytesize > render_length_limit
        raise_limits_reached
      end
    end

    def raise_limits_reached
      self.render_score = -1
      raise MemoryError, "Memory limits exceeded"
    end

    def reached?
      self.render_score == -1
    end

    def reset
      self.last_capture_length = nil
      self.render_score = self.assign_score = 0
    end

    def with_capture
      old_capture_length = last_capture_length
      begin
        self.last_capture_length = 0
        yield
      ensure
        self.last_capture_length = old_capture_length
      end
    end
  end
end
