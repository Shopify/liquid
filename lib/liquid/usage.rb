module Liquid
  # Usage is used to store
  class Usage
    @messages = {}
    class << self
      def enable
        Liquid::Context.send(:alias_method, :try_variable_find_in_environments, :try_variable_find_in_environments_usage)
      end

      def disable
        Liquid::Context.send(:alias_method, :try_variable_find_in_environments, :try_variable_find_in_environments_original)
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
