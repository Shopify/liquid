# frozen_string_literal: true

module Liquid
  class Optimizer
    def optimize(node)
      case node
      when Liquid::Template       then optimize(node.root.body)
      when Liquid::Document       then optimize(node.body)
      when Liquid::BlockBody      then optimize_block(node)
      when Liquid::Variable       then optimize_variable(node)
      when Liquid::Assign         then optimize_assign(node)
      when Liquid::For            then optimize_for(node)
      when Liquid::If             then optimize_if(node)
      end
      node
    end

    def optimize_block(block)
      block.nodelist.each { |node| optimize(node) }
    end

    def optimize_variable(node)
      # Turn chained `| append: "..."| append: "..."`, into a single `append_all: [...]`
      if node.filters.size > 1 && node.filters.all? { |f, _| f == "append" }
        node.filters = [["append_all", node.filters.map { |f, (arg)| arg }]]
      end
    end

    def optimize_assign(node)
      optimize(node.from)
    end

    def optimize_for(node)
      optimize(node.collection_name)
      optimize_block(node)
    end

    def optimize_if(node)
      node.blocks.each do |block|
        optimize_condition(block)
        optimize(block.attachment)
      end
    end

    def optimize_condition(node)
      case node
      when Liquid::ElseCondition
        # noop
      when Liquid::Condition
        optimize(node.left)
        optimize(node.right) if node.right
      end
    end
  end
end