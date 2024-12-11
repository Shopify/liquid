# frozen_string_literal: true

module Liquid
  class Loom
    class << self
      def optimize(template)
        new(template).optimize
      end
    end

    def initialize template
      @root = template.root
    end

    def optimize
      merge_if_blocks
    end

    def merge_if_blocks
      nodelist_list = [@root.nodelist]

      while nodelist_list.any?
        next_nodelist_list = []

        nodelist_list.each do |nodelist|
          i = 0
          while i < nodelist.length
            node = nodelist[i]
            chain_if_blocks(nodelist, node, i) if node.is_a?(If)
            i += 1
          end
        end

        nodelist_list = next_nodelist_list
      end
    end

    private

    def chain_if_blocks(nodelist, first_if_node, first_if_index)
      used_variables = Set.new

      # only check the top level Condition (ignore children conditions for now)
      first_if_node.blocks.each do |condition|
        used_variables << condition.left
        used_variables << condition.right if condition.right
      end

      if_blocks = []

      nodelist[first_if_index + 1..-1].each do |node|
        break unless node.is_a?(If)

        # check if the variables used in the current block are used in the previous block
        first_if_node.blocks.each do |condition|
          if used_variables.include?(condition.left) || (condition.right && used_variables.include?(condition.right))
            break
          end
        end

        if_blocks << node
      end

      nodelist.delete_if { |node| if_blocks.include?(node) }

      if_blocks.each do |if_block|
        first_if_node.blocks << if_block.blocks.first
      end
    end
  end
end
