# frozen_string_literal: true

module Liquid
  class StringScannerPool
    class << self
      def pop(input)
        @ss_pool ||= 5.times.each_with_object([]) { |_i, arr| arr << StringScanner.new("") }

        if @ss_pool.empty?
          StringScanner.new(input)
        else
          ss = @ss_pool.pop
          ss.string = input
          ss
        end
      end

      def release(ss)
        @ss_pool ||= []
        @ss_pool << ss
      end
    end
  end
end
