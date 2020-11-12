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
        to_integer(start_obj)..to_integer(end_obj)
      end
    end

    def self.to_integer(input)
      case input
      when Integer
        input
      when NilClass, String, Float
        input.to_i
      else
        Utils.to_integer(input)
      end
    end

    attr_reader :start_expr, :end_expr

    def initialize(start_expr, end_expr)
      @start_expr = start_expr
      @end_expr   = end_expr
    end

    def evaluate(context)
      start_int = self.class.to_integer(context.evaluate(@start_expr))
      end_int   = self.class.to_integer(context.evaluate(@end_expr))
      start_int..end_int
    end

    def ==(other)
      self.class == other.class && start_expr == other.start_expr && end_expr == other.end_expr
    end
  end
end
