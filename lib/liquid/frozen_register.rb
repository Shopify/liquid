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

    def delete(key)
      @registers.delete(key)
    end

    def fetch(key, default = nil)
      self[key] || default
    end

    def key?(key)
      self[key] != nil
    end

    def extract!(*keys)
      keys.each_with_object(@registers.class.new) { |key, result| result[key] = delete(key) if has_key?(key) }
    end

    def frozen
      @frozen_registers
    end
  end
end
