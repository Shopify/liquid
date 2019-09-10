module Liquid
  # A block interrupt is any command that breaks processing of a block (ex: a for loop).
  class BlockInterrupt
    attr_reader :message

    def initialize(message = nil)
      @message = message || "interrupt".freeze
    end
  end

  # Interrupt that is thrown whenever a {% break %} is called.
  class BreakInterrupt < BlockInterrupt; end

  # Interrupt that is thrown whenever a {% continue %} is called.
  class ContinueInterrupt < BlockInterrupt; end
end
