# frozen_string_literal: true

require 'test_helper'

class EnvironmentTest < Minitest::Test
  include Liquid

  class UnsubscribeFooter < Liquid::Tag
    def render(_context)
      'Unsubscribe Footer'
    end
  end

  def test_custom_tag
    email_environment = Liquid::Environment.build do |environment|
      environment.register_tag("unsubscribe_footer", UnsubscribeFooter)
    end

    assert(email_environment.tags["unsubscribe_footer"])
    assert(email_environment.tag_for_name("unsubscribe_footer"))
    template = Liquid::Template.parse("{% unsubscribe_footer %}", environment: email_environment)

    assert_equal('Unsubscribe Footer', template.render)
  end
end
