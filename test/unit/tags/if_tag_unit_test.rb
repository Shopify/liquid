# frozen_string_literal: true

require 'test_helper'

class IfTagUnitTest < Minitest::Test
  def test_if_nodelist
    template = Liquid::Template.parse('{% if true %}IF{% else %}ELSE{% endif %}')
    assert_equal(['IF', 'ELSE'], template.root.nodelist[0].nodelist.map(&:nodelist).flatten)
  end

  def test_support_truthy
    falsey = Class.new(Liquid::Drop) { def truthy? = false }.new
    truthy = Class.new(Liquid::Drop) { def truthy? = true }.new
    template = '{% if obj %}IF{% else %}ELSE{% endif %}'
    assert_template_result('ELSE', template, { 'obj' => falsey })
    assert_template_result('IF', template, { 'obj' => truthy })
    assert_template_result('IF', template, { 'obj' => "foo" }) # truthy? not defined
  end
end
