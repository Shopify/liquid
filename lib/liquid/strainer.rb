require 'set'

module Liquid

  parent_object = if defined? BlankObject
    BlankObject
  else
    Object
  end

  # Strainer is the parent class for the filters system.
  # New filters are mixed into the strainer class which is then instantiated for each liquid template render run.
  #
  # The Strainer only allows method calls defined in filters given to it via Strainer.global_filter,
  # Context#add_filters or Template.register_filter
  class Strainer < parent_object #:nodoc:
    @@filters = {}

    def initialize(context)
      @context = context
    end

    def self.global_filter(filter)
      raise ArgumentError, "Passed filter is not a module" unless filter.is_a?(Module)
      @@filters[filter.name] = filter
    end

    def self.create(context)
      strainer = Strainer.new(context)
      @@filters.each { |k,m| strainer.extend(m) }
      strainer
    end

    def invoke(method, *args)
      if has_method?(method)
        send(method, *args)
      else
        args.first
      end
    end

    private

    def has_method?(method)
      methods_to_check = self.methods - self.class.public_instance_methods
      methods_to_check.any? do |instance_method|
        instance_method.to_s == method.to_s
      end
    end

  end
end
