# frozen_string_literal: true

module Liquid
  class Template
    class TagRegistry
      include Enumerable

      def initialize(tags = nil)
        @tags  = {}
        @cache = {}
        tags.each { |tag_name, klass| self[tag_name] = klass }
        Deprecations.warn("Template::TagRegistry", "Use a World instance with zeitwerk")
      end

      def [](tag_name)
        return nil unless @tags.key?(tag_name)
        return @cache[tag_name] if Liquid.cache_classes

        lookup_class(@tags[tag_name]).tap { |o| @cache[tag_name] = o }
      end

      def delete(tag_name)
        Deprecations.warn("Template::TagRegistry#delete", "Use a World instance with immutable tags")
        @tags.delete(tag_name)
        @cache.delete(tag_name)
      end

      def []=(tag_name, klass)
        @tags[tag_name]  = klass.name
        @cache[tag_name] = klass
      end

      def each(&block)
        @tags.each(&block)
      end

      private

      def lookup_class(name)
        Object.const_get(name)
      end
    end
  end
end
