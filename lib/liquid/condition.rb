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
    attr_reader :attachment, :child_condition
    attr_accessor :left

    def initialize(left = nil)
      @left = left

      @child_relation  = nil
      @child_condition = nil
    end

    def evaluate(context = deprecated_default_context)
      condition = self
      result = nil
      loop do
        result = context.evaluate(condition.left)

        case condition.child_relation
        when :or
          break if Liquid::Utils.to_liquid_value(result)
        when :and
          break unless Liquid::Utils.to_liquid_value(result)
        else
          break
        end
        condition = condition.child_condition
      end
      result
    end

    def or(condition)
      @child_relation  = :or
      @child_condition = condition
    end

    def and(condition)
      @child_relation  = :and
      @child_condition = condition
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
          @node.child_condition,
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
