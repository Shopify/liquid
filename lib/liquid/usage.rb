module Liquid
  # Usage is used to store
  class Usage
    @messages = {}
    class << self
      def enable
        Dir["#{__dir__}/usages/*.rb"].each { |f| require f }
      end

      def track(message)
        @messages[message] = true
      end

      def results
        @messages
      end
    end
  end
end
