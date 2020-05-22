# frozen_string_literal: true

module Liquid
  class StaticRegisters
    attr_reader :static

    def initialize(registers = {})
      @static    = registers.is_a?(StaticRegisters) ? registers.static : registers
      @registers = {}
    end

    def []=(key, value)
      @registers[key] = value
    end

    def [](key)
      if @registers.key?(key)
        @registers[key]
      else
        @static[key]
      end
    end

    def delete(key)
      @registers.delete(key)
    end

    UNDEFINED = Object.new

    def fetch(key, default = UNDEFINED, &block)
      if @registers.key?(key)
        @registers.fetch(key)
      elsif default != UNDEFINED
        @static.fetch(key, default, &block)
      else
        @static.fetch(key, &block)
      end
    end

    def key?(key)
      @registers.key?(key) || @static.key?(key)
    end
  end
end
