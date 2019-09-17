module Liquid
  class FrozenRegister
    def initialize(registers = {})
      @frozen_registers = registers.is_a?(FrozenRegister) ? registers.frozen : registers
      @registers = {}
    end

    def []=(key, value)
      @registers[key] = value
    end

    def [](key)
      if @registers.key?(key)
        @registers[key]
      else
        @frozen_registers[key]
      end
    end

    def delete(key)
      @registers.delete(key)
    end

    def fetch(key, default = nil)
      self[key] || default
    end

    def key?(key)
      self[key] != nil
    end

    def frozen
      @frozen_registers
    end
  end
end
