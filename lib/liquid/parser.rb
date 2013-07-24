module Liquid
  # This class is used by tags to parse themselves
  # it provides helpers and encapsulates state
  class Parser
    def initialize(input)
      @tokens = tokenize(input)
      @p = 0 # pointer to current location
    end

    def tokenize(input)
      input.split(/\b/).map {|tok| tok.strip}
    end
  end
end
