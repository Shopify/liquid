# frozen_string_literal: true

module Liquid
  class MethodLiteral
    attr_reader :method_name, :to_s

    def initialize(method_name, to_s, &evaluator)
      @method_name = method_name
      @to_s = to_s
      @evaluator = evaluator
    end

    def apply(value)
      if value.respond_to?(@method_name)
        value.send(@method_name)
      elsif @evaluator
        @evaluator.call(value)
      end
    end

    def to_liquid
      to_s
    end

    BLANK = MethodLiteral.new(:blank?, '') do |value|
      case value
      when NilClass, FalseClass
        true
      when TrueClass, Numeric
        false
      when String
        value.empty? || value.match?(/\A\s*\z/)
      when Array, Hash
        value.empty?
      else
        value.respond_to?(:empty?) ? value.empty? : false
      end
    end.freeze

    EMPTY = MethodLiteral.new(:empty?, '') do |value|
      case value
      when String, Array, Hash
        value.empty?
      else
        value.respond_to?(:empty?) ? value.empty? : nil
      end
    end.freeze
  end
end
