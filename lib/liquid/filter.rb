# frozen_string_literal: true

require 'set'

module Liquid
  # A filter in liquid is a class which contain invokable logic from liquid templates.
  #
  # Public methods in filter classes are callable.
  #
  # The use for liquid filters is to make logic functions available to the web designers.
  #
  # Example:
  #
  #   class StringFilter < Liquid::Filter
  #     def upcase(input)
  #       input.upcase
  #     end
  #   end
  #
  #   tmpl = Liquid::Template.parse('Result: {{ "test" | upcase }}')
  #   tmpl.render({}, filters: [StringFilter])
  #   => "Result: TEST"
  class Filter
    class << self
      def invokable_methods
        @invokable_methods ||= begin
          blacklist = Liquid::Filter.public_instance_methods
          whitelist = public_instance_methods - blacklist

          Set.new(whitelist.map(&:to_s))
        end
      end
    end

    attr_accessor :context
  end
end
