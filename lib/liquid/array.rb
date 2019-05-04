module Liquid
  module Array
    def empty(input)
      input.empty?
    end

    def count(input)
      input.count
    end

    alias_method :length, :count
  end

  Template.register_filter(Array)
end
