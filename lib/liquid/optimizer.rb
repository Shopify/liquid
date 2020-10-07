# frozen_string_literal: true

module Liquid
  class Optimizer
    class << self
      attr_accessor :enabled

      def optimize_variable(node)
        return unless enabled

        # Turn chained `| append: "..."| append: "..."`, into a single `append_all: [...]`
        if node.filters.size > 1 && node.filters.all? { |f, _| f == "append" }
          node.filters = [["append_all", node.filters.map { |f, (arg)| arg }]]
        end
      end
    end
    self.enabled = true
  end
end