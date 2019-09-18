# frozen_string_literal: true
module Liquid
  class DisabledTags < Register
    def initialize
      @disabled_tags = Hash.new { |h, k| h[k] = 0 }
    end

    def disabled?(tag)
      @disabled_tags[tag] > 0
    end

    def disable(tag)
      incr(tag)
      yield
    ensure
      decr(tag)
    end

    private

    def incr(tag)
      @disabled_tags[tag] = @disabled_tags[tag] + 1
    end

    def decr(tag)
      @disabled_tags[tag] = @disabled_tags[tag] - 1
    end
  end

  Template.register_register('disabled_tags', DisabledTags.new)
end
