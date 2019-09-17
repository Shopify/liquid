module Liquid
  class FrozenRegister
    def self.new_with_frozen(existing)
      if existing.is_a?(FrozenRegister)
        FrozenRegister.new(existing.frozen)
      else
        FrozenRegister.new(existing)
      end
    end

    def initialize(registers = {})
      @frozen_registers = registers.freeze
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

    def frozen
      @frozen_registers
    end
  end
end
