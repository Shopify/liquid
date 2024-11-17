module Liquid
  class StringScannerPool
    class << self
      def pop(input)
        @ss_pool ||= [StringScanner.new("")] * 5

        if @ss_pool.empty?
          StringScanner.new(input)
        else
          ss = @ss_pool.pop
          ss.string = input
          ss
        end
      end

      def release(ss)
        binding.irb if ss.nil?
        @ss_pool ||= []
        @ss_pool << ss
      end
    end
  end
end
