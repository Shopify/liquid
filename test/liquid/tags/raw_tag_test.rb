require 'test_helper'

class RawTagTest < Test::Unit::TestCase
  include Liquid

  def test_tag_in_raw
    assert_template_result '{% comment %} test {% endcomment %}',
                           '{% raw %}{% comment %} test {% endcomment %}{% endraw %}'
  end

  def test_output_in_raw
    assert_template_result '{{ test }}',
                           '{% raw %}{{ test }}{% endraw %}'
  end
end
