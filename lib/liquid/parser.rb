module Liquid
  # This class is used by tags to parse themselves
  # it provides helpers and encapsulates state
  class Parser
    def initialize(input)
      @input = input
      @p = 0 # pointer to current location
    end
  end
end
