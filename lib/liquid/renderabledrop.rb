# frozen_string_literal: true

module Liquid
  class RenderableDrop < Drop
    def render(_context, _output)
      raise NotImplementedError, "render must be implemented for #{self.class.name}"
    end
  end
end
