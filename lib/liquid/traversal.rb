# frozen_string_literal: true

module Liquid
  class Traversal
    def self.for(node, callbacks = Hash.new(proc {}))
      kase = CASES.find { |(klass, _)| node.is_a?(klass) }&.last
      (kase || self).new(node, callbacks)
    end

    def initialize(node, callbacks)
      @node = node
      @callbacks = callbacks
    end

    def callback_for(*classes, &block)
      callback = block
      callback = ->(node, _) { block.call(node) } if block.arity.abs == 1
      callback = ->(_, _) { block.call } if block.arity.zero?
      classes.each { |klass| @callbacks[klass] = callback }
      self
    end

    def traverse(context = nil)
      children.map do |node|
        item, new_context = @callbacks[node.class].call(node, context)
        [
          item,
          Traversal.for(node, @callbacks).traverse(new_context || context)
        ]
      end
    end

    protected

    def children
      @node.respond_to?(:nodelist) ? Array(@node.nodelist) : []
    end

    class Assign < Traversal
      def children
        [@node.from]
      end
    end

    class Case < Traversal
      def children
        [@node.left] + @node.blocks
      end
    end

    class Condition < Traversal
      def children
        [
          @node.left, @node.right,
          @node.child_condition, @node.attachment
        ].compact
      end
    end

    class Cycle < Traversal
      def children
        Array(@node.variables)
      end
    end

    class For < Traversal
      def children
        (super + [@node.limit, @node.from, @node.collection_name]).compact
      end
    end

    class If < Traversal
      def children
        @node.blocks
      end
    end

    class Include < Traversal
      def children
        [
          @node.template_name_expr,
          @node.variable_name_expr
        ] + @node.attributes.values
      end
    end

    class TableRow < Traversal
      def children
        super + @node.attributes.values + [@node.collection_name]
      end
    end

    class Variable < Traversal
      def children
        [@node.name] + @node.filters.flatten
      end
    end

    class VariableLookup < Traversal
      def children
        @node.lookups
      end
    end

    CASES = {
      Liquid::Assign => Assign,
      Liquid::Case => Case,
      Liquid::Condition => Condition,
      Liquid::Cycle => Cycle,
      Liquid::For => For,
      Liquid::If => If,
      Liquid::Include => Include,
      Liquid::TableRow => TableRow,
      Liquid::Variable => Variable,
      Liquid::VariableLookup => VariableLookup
    }.freeze
  end
end
