# frozen_string_literal: true

module Liquid
  class StaticRegisters
    attr_reader :static, :registers

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

    def fetch(key, default = nil)
      key?(key) ? self[key] : default
    end

    def key?(key)
      @registers.key?(key) || @static.key?(key)
    end
  end
end
