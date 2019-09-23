# frozen_string_literal: true

require 'test_helper'

class DisabledTagsTest < Minitest::Test
  include Liquid

  class DisableRaw < Block
    def render(context)
      disable_tags(context, ["raw"]) do
        @body.render(context)
      end
    end
  end

  class DisableRawEcho < Block
    def render(context)
      disable_tags(context, ["raw", "echo"]) do
        @body.render(context)
      end
    end
  end

  def test_disables_raw
    with_custom_tag('disable', DisableRaw) do
      assert_template_result 'raw usage has been disabled in this context.foo', '{% disable %}{% raw %}Foobar{% endraw %}{% echo "foo" %}{% enddisable %}'
    end
  end

  def test_disables_echo_and_raw
    with_custom_tag('disable', DisableRawEcho) do
      assert_template_result 'raw usage has been disabled in this context.echo usage has been disabled in this context.', '{% disable %}{% raw %}Foobar{% endraw %}{% echo "foo" %}{% enddisable %}'
    end
  end
end
