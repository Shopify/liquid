# frozen_string_literal: true

module Liquid
  class RangeLookup
    def self.parse(start_markup, end_markup)
      start_obj = Expression.parse(start_markup)
      end_obj   = Expression.parse(end_markup)
      if start_obj.respond_to?(:evaluate) || end_obj.respond_to?(:evaluate)
        new(start_obj, end_obj)
      else
        begin
          start_obj.to_i..end_obj.to_i
        rescue NoMethodError
          invalid_expr = start_markup unless start_obj.respond_to?(:to_i)
          invalid_expr ||= end_markup unless end_obj.respond_to?(:to_i)
          if invalid_expr
            raise Liquid::SyntaxError, "Invalid expression type '#{invalid_expr}' in range expression"
          end

          raise
        end
      end
    end

    def self.lax_migrate(start_markup, end_markup)
      new_start = Expression.lax_migrate(start_markup)
      new_end = Expression.lax_migrate(end_markup)

      # cast literals
      start_obj = Expression.parse(new_start)
      end_obj   = Expression.parse(new_end)
      if start_obj.respond_to?(:evaluate) || end_obj.respond_to?(:evaluate)
        new_start = lax_migrate_range_expression(new_start, start_obj)
        new_end = lax_migrate_range_expression(new_end, end_obj)
      else
        new_start = start_obj.to_i.to_s unless start_obj.is_a?(Integer)
        new_end = end_obj.to_i.to_s unless end_obj.is_a?(Integer)
      end

      [new_start, new_end]
    end

    def self.lax_migrate_range_expression(markup, expression)
      return markup if expression.respond_to?(:evaluate)

      case expression
      when Integer
        markup
      when NilClass, String
        expression.to_i.to_s
      else
        Utils.to_integer(input).to_s
      end
    end

    attr_reader :start_obj, :end_obj

    def initialize(start_obj, end_obj)
      @start_obj = start_obj
      @end_obj   = end_obj
    end

    def evaluate(context)
      start_int = to_integer(context.evaluate(@start_obj))
      end_int   = to_integer(context.evaluate(@end_obj))
      start_int..end_int
    end

    private

    def to_integer(input)
      case input
      when Integer
        input
      when NilClass, String
        input.to_i
      else
        Utils.to_integer(input)
      end
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.start_obj, @node.end_obj]
      end
    end
  end
end
