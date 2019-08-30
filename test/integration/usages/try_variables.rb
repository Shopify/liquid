module Liquid
  class Context
    remove_method :try_variable_find_in_environments
    def try_variable_find_in_environments(key, raise_on_not_found:)
      Usage.track("Using try_variable_find_in_environment")
      @environments.each do |environment|
        found_variable = lookup_and_evaluate(environment, key, raise_on_not_found: raise_on_not_found)
        if !found_variable.nil? || @strict_variables && raise_on_not_found
          return found_variable
        end
        Usage.track("try_variable_find_in_environment reports Nil but responds to key") if environment.key?(key)
      end
      @static_environments.each do |environment|
        found_variable = lookup_and_evaluate(environment, key, raise_on_not_found: raise_on_not_found)
        if !found_variable.nil? || @strict_variables && raise_on_not_found
          return found_variable
        end
        Usage.track("try_variable_find_in_environment reports Nil but responds to key") if environment.key?(key)
      end
      nil
    end
  end
end
