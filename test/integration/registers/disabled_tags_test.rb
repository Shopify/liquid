# frozen_string_literal: true

require 'test_helper'

class DisabledTagsTest < Minitest::Test
  include Liquid

  class DisableRaw < Block
    disable_tags "raw"
  end

  class DisableRawEcho < Block
    disable_tags "raw", "echo"
  end

  def test_disables_raw
    with_custom_tag('disable', DisableRaw) do
      assert_template_result 'raw usage is not allowed in this contextfoo', '{% disable %}{% raw %}Foobar{% endraw %}{% echo "foo" %}{% enddisable %}'
    end
  end

  def test_disables_echo_and_raw
    with_custom_tag('disable', DisableRawEcho) do
      assert_template_result 'raw usage is not allowed in this contextecho usage is not allowed in this context', '{% disable %}{% raw %}Foobar{% endraw %}{% echo "foo" %}{% enddisable %}'
    end
  end
end
