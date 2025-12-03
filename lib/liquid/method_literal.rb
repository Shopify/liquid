# frozen_string_literal: true

module Liquid
  class MethodLiteral
    attr_reader :method_name, :to_s

    def initialize(method_name, to_s)
      @method_name = method_name
      @to_s = to_s
    end

    def to_liquid
      to_s
    end
  end
end
