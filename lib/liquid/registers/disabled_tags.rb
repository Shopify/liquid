# frozen_string_literal: true
module Liquid
  class DisabledTags < Register
    def initialize
      @disabled_tags = {}
    end

    def disabled?(tag)
      @disabled_tags.key?(tag) && @disabled_tags[tag] > 0
    end

    def disable(tags)
      tags.each(&method(:increment))
      yield
    ensure
      tags.each(&method(:decrement))
    end

    private

    def increment(tag)
      @disabled_tags[tag] ||= 0
      @disabled_tags[tag]  += 1
    end

    def decrement(tag)
      @disabled_tags[tag] -= 1
    end
  end

  Template.add_register(:disabled_tags, DisabledTags.new)
end
