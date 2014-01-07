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
      name.gsub(/%\{(\w+)\}/) {
        # raise TranslationError, "Undefined key #{$1} for interpolation in translation #{name}"  unless vars[$1.to_sym]
        "#{vars[$1.to_sym]}"
      }
    end

    def deep_fetch_translation(name)
      name.split('.'.freeze).reduce(locale) do |level, cur|
        level[cur] or raise TranslationError, "Translation for #{name} does not exist in locale #{path}"
      end
    end
  end
end
