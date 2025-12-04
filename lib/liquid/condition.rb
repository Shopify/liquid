# frozen_string_literal: true

module Liquid
  # Container for liquid nodes which conveniently wraps decision making logic
  #
  # Example:
  #
  #   c = Condition.new(expr)
  #   c.evaluate #=> true
  #
  class Condition # :nodoc:
    attr_reader :attachment
    attr_accessor :left

    def initialize(left = nil)
      @left = left
    end

    def evaluate(context = deprecated_default_context)
      context.evaluate(left)
    end

    def attach(attachment)
      @attachment = attachment
    end

    def else?
      false
    end

    def inspect
      "#<Condition #{[@left, @operator, @right].compact.join(' ')}>"
    end

    protected

    attr_reader :child_relation

    private

    def deprecated_default_context
      warn("DEPRECATION WARNING: Condition#evaluate without a context argument is deprecated" \
        " and will be removed from Liquid 6.0.0.")
      Context.new
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [
          @node.left,
          @node.attachment
        ].compact
      end
    end
  end

  class ElseCondition < Condition
    def else?
      true
    end

    def evaluate(_context)
      true
    end
  end
end
