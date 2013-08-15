require 'yaml'
require 'delegate'

module Liquid
  class I18n
    class TranslationError < StandardError
    end

    def initialize(path)
      @path = path
    end

    def translate(name, vars = {})
      interpolate(deep_fetch_translation(name), vars)
    end
    alias_method :t, :translate

    class << self
      def translate(name, vars = {})
        @@global.translate(name, vars)
      end
      alias_method :t, :translate

      def global=(translator)
        @@global = translator
      end
    end

    private
    def interpolate(name, vars)
      name.gsub(/:(\w+)/) do
        vars[$1.to_sym] or raise TranslationError, translate("errors.i18n.undefined_interpolation", :key => $1, :name => name)
      end
    end

    def deep_fetch_translation(name)
      name.split('.').reduce(locale) do |level, cur|
        level[cur] or raise TranslationError, translate("errors.i18n.unknown_translation", :name => name)
      end
    end

    def locale
      @locale ||= YAML.load_file(@path)
    end
  end
end
