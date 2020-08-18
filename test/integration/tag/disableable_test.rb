# frozen_string_literal: true

require 'test_helper'

class TagDisableableTest < Minitest::Test
  include Liquid

  class DisableRaw < Block
    disable_tags "raw"
  end

  class DisableRawEcho < Block
    disable_tags "raw", "echo"
  end

  class DisableableRaw < Liquid::Raw
    prepend Liquid::Tag::Disableable
  end

  class DisableableEcho < Liquid::Echo
    prepend Liquid::Tag::Disableable
  end

  def test_disables_raw
    with_disableable_tags do
      with_custom_tag('disable', DisableRaw) do
        assert_template_result 'raw usage is not allowed in this contextfoo', '{% disable %}{% raw %}Foobar{% endraw %}{% echo "foo" %}{% enddisable %}'
      end
    end
  end

  def test_disables_echo_and_raw
    with_disableable_tags do
      with_custom_tag('disable', DisableRawEcho) do
        assert_template_result 'raw usage is not allowed in this contextecho usage is not allowed in this context', '{% disable %}{% raw %}Foobar{% endraw %}{% echo "foo" %}{% enddisable %}'
      end
    end
  end

  private

  def with_disableable_tags
    with_custom_tag('raw', DisableableRaw) do
      with_custom_tag('echo', DisableableEcho) do
        yield
      end
    end
  end
end
