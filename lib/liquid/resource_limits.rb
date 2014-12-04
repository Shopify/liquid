module Liquid
  class ResourceLimits
    attr_accessor :render_length, :render_score, :assign_score,
                  :render_length_limit, :render_score_limit, :assign_score_limit

    def initialize(limits)
      @render_length_limit = limits[:render_length_limit]
      @render_score_limit = limits[:render_score_limit]
      @assign_score_limit = limits[:assign_score_limit]

      # render_length is assigned by BlockBody
      @render_score = 0
      @assign_score = 0
    end

    def reached?
      (@render_length_limit && @render_length > @render_length_limit) ||
      (@render_score_limit  && @render_score  > @render_score_limit ) ||
      (@assign_score_limit  && @assign_score  > @assign_score_limit )
    end

    def increment_render_length(obj)
      @render_length += increment_for(obj)
    end

    def increment_render_score(obj)
      @render_score += increment_for(obj)
    end

    def increment_assign_score(obj)
      @assign_score += increment_for(obj)
    end

    private
    def increment_for(obj)
      obj.instance_of?(String) || obj.instance_of?(Array) || obj.instance_of?(Hash) ? obj.length : 1
    end
  end
end
