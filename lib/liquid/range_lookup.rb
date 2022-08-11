# frozen_string_literal: true

module Liquid
  class RangeLookup
    def self.parse(start_markup, end_markup)
      start_obj = Expression.parse(start_markup)
      end_obj   = Expression.parse(end_markup)
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
      when NilClass, String
        input.to_i
      else
        Utils.to_integer(input)
      end
    end

    attr_reader :start_obj, :end_obj

    def initialize(start_obj, end_obj)
      @start_obj = start_obj
      @end_obj   = end_obj
    end

    def evaluate(context)
      start_int = RangeLookup.to_integer(context.evaluate(@start_obj))
      end_int   = RangeLookup.to_integer(context.evaluate(@end_obj))
      start_int..end_int
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.start_obj, @node.end_obj]
      end
    end
  end
end
