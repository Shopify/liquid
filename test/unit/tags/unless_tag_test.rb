# frozen_string_literal: true

require 'test_helper'

class IfTagUnitTest < Minitest::Test
  def test_support_truthy
    falsey = Class.new(Liquid::Drop) { def truthy? = false }.new
    truthy = Class.new(Liquid::Drop) { def truthy? = true }.new
    template = '{% unless obj %}IF{% else %}ELSE{% endunless %}'
    assert_template_result('ELSE', template, { 'obj' => truthy })
    assert_template_result('IF', template, { 'obj' => falsey })
    assert_template_result('ELSE', template, { 'obj' => "truthy? not defined" })
  end
end
