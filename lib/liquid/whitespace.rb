module Liquid
  class Whitespace
    attr_reader :content

    def initialize(content = nil)
      @content = content || "".freeze
    end

    def format(left, right)
      @content
    end
  end
end
