# frozen_string_literal: true

require 'test_helper'
require 'open3'
require 'rbconfig'

class StrscanUnitTest < Minitest::Test
  def test_liquid_does_not_load_strscan
    script = <<~RUBY
      require "liquid"
      Liquid::Template.parse("{% if a > 1.5 %}{{ b | append: 'c' }}{% endif %}", error_mode: :strict).render("a" => 2)
      Liquid::Template.parse("{% assign x = (1..3) %}{{ x | join: ',' }}", error_mode: :lax).render
      Liquid::Template.parse("{{ a['b'].c }}", error_mode: :strict2).render
      exit($LOADED_FEATURES.none? { |feature| feature.include?("strscan") })
    RUBY
    lib = File.expand_path("../../lib", __dir__)
    _, status = Open3.capture2e(RbConfig.ruby, "-I", lib, "-e", script)

    assert_predicate(status, :success?)
  end
end
