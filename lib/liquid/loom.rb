# frozen_string_literal: true

module Liquid
  class Loom
    MERGABLE_IF_OPERATORS = ["==", ">", "<", "!="].freeze
    EQUAL_OP = "==".freeze

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

    def mergable_if_blocks?(target_if, next_if)
      target_left = target_if.blocks.first.left
      target_right = target_if.blocks.first.right
      next_left = next_if.blocks.first.left
      next_right = next_if.blocks.first.right

      used_variables = Hash.new { |h, k| h[k] = 0 }

      [
        target_if.blocks.first.left,
        target_if.blocks.first.right,
        next_if.blocks.first.left,
        next_if.blocks.first.right
      ].each do |var|
        if var.is_a?(VariableLookup)
          used_variables[var.name] += 1
        end
      end

      return if used_variables.keys.count > 1

      most_used_variable_name = used_variables.keys[0]

      # TODO: I probably can't do this
      # It might be possible to get different result between a > b and b < a
      # Move most commonly used variable to the left side
      if (target_left.is_a?(VariableLookup) && target_left.name != most_used_variable_name) || (target_right.is_a?(VariableLookup) && target_right.name == most_used_variable_name)
        target_left, target_right = target_right, target_left
      end

      if (next_left.is_a?(VariableLookup) && next_left.name != most_used_variable_name) || (next_right.is_a?(VariableLookup) && next_right.name == most_used_variable_name)
        next_left, next_right = next_right, next_left
      end

      return false unless target_left.is_a?(VariableLookup) && next_left.is_a?(VariableLookup)
      return false if target_left.name != next_left.name

      return false if target_right.nil? || next_right.nil?


      # we need to be conversative here and only can merge ==, >, <, and != operators
      target_operator = target_if.blocks.first.operator
      next_operator = next_if.blocks.first.operator

      return false unless MERGABLE_IF_OPERATORS.include?(target_operator) && MERGABLE_IF_OPERATORS.include?(next_operator)

      return false if target_operator == next_operator && target_right == next_right

      return false if target_right.is_a?(VariableLookup) || next_right.is_a?(VariableLookup)

      true
    end

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
        break unless mergable_if_blocks?(first_if_node, node)

        if_blocks << node
      end

      nodelist.delete_if { |node| if_blocks.include?(node) }

      if_blocks.each do |if_block|
        first_if_node.blocks << if_block.blocks.first
      end
    end
  end
end
