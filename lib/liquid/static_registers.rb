# frozen_string_literal: true

module Liquid
  class StaticRegisters
    attr_reader :static, :registers

    def initialize(registers = {})
      @static    = registers.is_a?(StaticRegisters) ? registers.static : registers
      @registers = {}

      @cache = @static.dup
    end

    def []=(key, value)
      @registers[key] = value
      @cache[key] = value
    end

    def [](key)
      @cache[key]
    end

    def delete(key)
      @registers.delete(key).tap do
        @static.dup.merge(@registers)
      end
    end

    def fetch(key, default = nil)
      key?(key) ? self[key] : default
    end

    def key?(key)
      @cache.key?(key)
    end
  end
end
