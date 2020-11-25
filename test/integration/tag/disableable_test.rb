# frozen_string_literal: true

require 'test_helper'

class TagDisableableTest < Minitest::Test
  include Liquid

  module RenderTagName
    def render(_context)
      tag_name
    end
  end

  class Custom < Tag
    prepend Liquid::Tag::Disableable
    include RenderTagName
  end

  class Custom2 < Tag
    prepend Liquid::Tag::Disableable
    include RenderTagName
  end

  class DisableCustom < Block
    disable_tags "custom"
  end

  class DisableBoth < Block
    disable_tags "custom", "custom2"
  end

  def test_block_tag_disabling_nested_tag
    with_disableable_tags do
      with_custom_tag('disable', DisableCustom) do
        output = Template.parse('{% disable %}{% custom %};{% custom2 %}{% enddisable %}').render
        assert_equal('Liquid error: custom usage is not allowed in this context;custom2', output)
      end
    end
  end

  def test_block_tag_disabling_multiple_nested_tags
    with_disableable_tags do
      with_custom_tag('disable', DisableBoth) do
        output = Template.parse('{% disable %}{% custom %};{% custom2 %}{% enddisable %}').render
        assert_equal('Liquid error: custom usage is not allowed in this context;Liquid error: custom2 usage is not allowed in this context', output)
      end
    end
  end

  private

  def with_disableable_tags
    with_custom_tag('custom', Custom) do
      with_custom_tag('custom2', Custom2) do
        yield
      end
    end
  end
end
