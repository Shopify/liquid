# frozen_string_literal: true

module Liquid
  class StaticRegisters
    attr_reader :static_registers, :registers

    def initialize(registers = {})
      @static_registers = registers.is_a?(StaticRegisters) ? registers.static_registers : registers.freeze
      @registers = {}
    end

    def []=(key, value)
      @registers[key] = value
    end

    def [](key)
      if @registers.key?(key)
        @registers[key]
      else
        @static_registers[key]
      end
    end

    def delete(key)
      @registers.delete(key)
    end

    def fetch(key, default = nil)
      key?(key) ? self[key] : default
    end

    def key?(key)
      @registers.key?(key) || @static_registers.key?(key)
    end
  end
end
