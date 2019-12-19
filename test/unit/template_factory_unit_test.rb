# frozen_string_literal: true

require 'test_helper'

class TemplateFactoryUnitTest < Minitest::Test
  include Liquid

  def test_for_returns_liquid_template_instance
    template = TemplateFactory.new.for("anything")
    assert_instance_of(Liquid::Template, template)
  end
end
