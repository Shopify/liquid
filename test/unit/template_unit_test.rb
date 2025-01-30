# frozen_string_literal: true

require 'test_helper'

class TemplateUnitTest < Minitest::Test
  include Liquid

  def test_sets_default_localization_in_document
    t = Template.new
    t.parse('{%comment%}{%endcomment%}')
    assert_instance_of(I18n, t.root.nodelist[0].options[:locale])
  end

  def test_sets_default_localization_in_context_with_quick_initialization
    t = Template.new
    t.parse('{%comment%}{%endcomment%}', locale: I18n.new(fixture("en_locale.yml")))

    locale = t.root.nodelist[0].options[:locale]
    assert_instance_of(I18n, locale)
    assert_equal(fixture("en_locale.yml"), locale.path)
  end

  class FakeTag; end

  def test_tags_can_be_looped_over
    with_custom_tag('fake', FakeTag) do
      result = Template.tags.map { |name, klass| [name, klass] }
      assert(result.include?(["fake", TemplateUnitTest::FakeTag]))
    end
  end

  class TemplateSubclass < Liquid::Template
  end

  def test_template_inheritance
    assert_equal("foo", TemplateSubclass.parse("foo").render)
  end

  def test_invalid_utf8
    input = "\xff\x00"
    error = assert_raises(SyntaxError) do
      Liquid::Tokenizer.new(source: input, string_scanner: StringScanner.new(input))
    end
    assert_equal(
      'Liquid syntax error: Invalid byte sequence in UTF-8',
      error.message,
    )
  end
end
