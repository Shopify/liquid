require 'test_helper'

class TemplateUnitTest < Test::Unit::TestCase
  include Liquid

  def test_sets_default_localization_in_document
    t = Template.new
    t.parse('')
    assert_instance_of I18n, t.root.options[:locale]
  end

  def test_sets_default_localization_in_context_with_quick_initialization
    t = Template.new
    t.parse('{{foo}}', :locale => I18n.new(fixture("en_locale.yml")))

    assert_instance_of I18n, t.root.options[:locale]
    assert_equal fixture("en_locale.yml"), t.root.options[:locale].path
  end
end
