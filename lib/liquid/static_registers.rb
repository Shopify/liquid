module Liquid
  class StaticRegisters
    def initialize(registers = {})
      @static_registers = registers.is_a?(StaticRegisters) ? registers.static : registers.freeze
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
      self[key] || default
    end

    def key?(key)
      self[key] != nil
    end

    def static
      @static_registers
    end
  end
end
