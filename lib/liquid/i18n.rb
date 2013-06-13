require 'i18n'

I18n.load_path << Dir[File.join(File.dirname(__FILE__), '..', 'locale', '*.yml')]
