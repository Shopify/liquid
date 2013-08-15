require 'yaml'

module Liquid
  class I18n
    DEFAULT_LOCALE = File.join(File.expand_path(File.dirname(__FILE__)), "locales", "en.yml")

    class TranslationError < StandardError
    end
    
    attr_reader :path

    def initialize(path = DEFAULT_LOCALE)
      @path = path
    end

    def translate(name, vars = {})
      interpolate(deep_fetch_translation(name), vars)
    end
    alias_method :t, :translate

    def locale
      @locale ||= YAML.load_file(@path)
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
  end
end
