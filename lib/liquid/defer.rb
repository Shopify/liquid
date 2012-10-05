module Liquid
  class Defer

    attr_reader :base
    def initialize(base)
      @base=base
    end

    def to_liquid
      self
    end

  end
end
