# frozen_string_literal: true

require 'forwardable'

module Liquid
  class StaticRegisters
    extend Forwardable

    attr_reader :static, :registers

    def_delegators :@cache, :[], :key?

    def initialize(registers = {})
      @static    = registers.is_a?(StaticRegisters) ? registers.static : registers
      @registers = {}

      @cache = @static.dup
    end

    def []=(key, value)
      @registers[key] = value
      @cache[key] = value
    end

    def delete(key)
      deleted = @registers.delete(key)
      @cache = @static.dup.merge(@registers)
      deleted
    end

    def fetch(key, default = nil)
      key?(key) ? self[key] : default
    end
  end
end
