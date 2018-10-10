# frozen_string_literal: true

module Liquid
  class Traversal
    def self.for(node, callbacks = Hash.new(proc {}))
      if defined?(node.class::Traversal)
        node.class::Traversal
      else
        self
      end.new(node, callbacks)
    end

    def initialize(node, callbacks)
      @node = node
      @callbacks = callbacks
    end

    def add_callback_for(*classes, &block)
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
  end
end
