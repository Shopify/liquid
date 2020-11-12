# frozen_string_literal: true

module Liquid
  class RangeLookup
    def self.parse(start_markup, end_markup)
      start_obj = Expression.parse(start_markup)
      end_obj   = Expression.parse(end_markup)
      build(start_obj, end_obj)
    end

    def self.build(start_obj, end_obj)
      if start_obj.respond_to?(:evaluate) || end_obj.respond_to?(:evaluate)
        new(start_obj, end_obj)
      else
        start_obj.to_i..end_obj.to_i
      end
    end

    attr_reader :start_expr, :end_expr

    def initialize(start_expr, end_expr)
      @start_expr = start_expr
      @end_expr   = end_expr
    end

    def evaluate(context)
      start_int = to_integer(context.evaluate(@start_expr))
      end_int   = to_integer(context.evaluate(@end_expr))
      start_int..end_int
    end

    def ==(other)
      self.class == other.class && start_expr == other.start_expr && end_expr == other.end_expr
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
  end
end
