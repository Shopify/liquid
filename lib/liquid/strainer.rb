require 'set'

module Liquid

  # Strainer is the parent class for the filters system.
  # New filters are mixed into the strainer class which is then instantiated for each liquid template render run.
  #
  # The Strainer only allows method calls defined in filters given to it via Strainer.global_filter,
  # Context#add_filters or Template.register_filter
  class Strainer #:nodoc:
    @@filters = []
    @@known_filters = Set.new
    @@known_methods = Set.new
    @@strainer_class_cache = Hash.new do |hash, filters|
      hash[filters] = Class.new(Strainer) do
        filters.each { |f| include f }
      end
    end

    def initialize(context)
      @context = context
    end

    def self.global_filter(filter)
      raise ArgumentError, "Passed filter is not a module" unless filter.is_a?(Module)
      add_known_filter(filter)
      @@filters << filter unless @@filters.include?(filter)
    end

    def self.add_known_filter(filter)
      unless @@known_filters.include?(filter)
        @@method_blacklist ||= Set.new(Strainer.instance_methods.map(&:to_s))
        new_methods = filter.instance_methods.map(&:to_s)
        new_methods.reject!{ |m| @@method_blacklist.include?(m) }
        @@known_methods.merge(new_methods)
        @@known_filters.add(filter)
      end
    end

    def self.strainer_class_cache
      @@strainer_class_cache
    end

    def self.create(context, filters = [])
      filters = @@filters + filters
      strainer_class_cache[filters].new(context)
    end

    def invoke(method, *args)
      if invokable?(method)
        send(method, *args)
      else
        args.first
      end
    rescue ::ArgumentError => e
      raise Liquid::ArgumentError.new(e.message)
    end

    def invokable?(method)
      @@known_methods.include?(method.to_s) && respond_to?(method)
    end
  end
end
