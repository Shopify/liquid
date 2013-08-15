require 'test_helper'

class I18nTest < Test::Unit::TestCase
  include Liquid

  def en_locale_path
    File.join(File.expand_path(File.dirname(__FILE__)), "..", "fixtures", "en_locale.yml")
  end

  def setup
    @i18n = I18n.new en_locale_path
  end

  def test_simple_translate_string
    assert_equal "less is more", @i18n.translate("simple")
  end

  def test_nested_translate_string
    assert_equal "something wasn't right", @i18n.translate("errors.syntax.oops")
  end

  def test_single_string_interpolation
    assert_equal "something different", @i18n.translate("whatever", :something => "different")
  end

  def test_raises_keyerror_on_undefined_interpolation_key
    assert_raise I18n::TranslationError do
      @i18n.translate("whatever", :oopstypos => "yes")
    end
  end
  
  def test_raises_unknown_translation
    assert_raise I18n::TranslationError do
      @i18n.translate("doesnt_exist")
    end
  end
end
