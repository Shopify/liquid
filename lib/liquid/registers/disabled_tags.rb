# frozen_string_literal: true
module Liquid
  class DisabledTags < Register
    def initialize
      @disabled_tags = Hash.new { |h, k| h[k] = 0 }
    end

    def disabled?(tag)
      @disabled_tags[tag] > 0
    end

    def disable(tags)
      tags.each { |tag| increment(tag) }
      yield
    ensure
      tags.each { |tag| decrement(tag) }
    end

    private

    def increment(tag)
      @disabled_tags[tag] = @disabled_tags[tag] + 1
    end

    def decrement(tag)
      @disabled_tags[tag] = @disabled_tags[tag] - 1
    end
  end

  Template.register_register('disabled_tags', DisabledTags.new)
end
