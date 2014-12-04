#!/usr/bin/env ruby

require 'minitest/autorun'
require 'spy/integration'

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib'))
require 'liquid.rb'
require 'liquid/profiler'

mode = :strict
if env_mode = ENV['LIQUID_PARSER_MODE']
  puts "-- #{env_mode.upcase} ERROR MODE"
  mode = env_mode.to_sym
end
Liquid::Template.error_mode = mode

if Minitest.const_defined?('Test')
  # We're on Minitest 5+. Nothing to do here.
else
  # Minitest 4 doesn't have Minitest::Test yet.
  Minitest::Test = MiniTest::Unit::TestCase
end

module Minitest
  class Test
    def fixture(name)
      File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", name)
    end
  end

  module Assertions
    include Liquid

    def assert_template_result(expected, template, assigns = {}, message = nil)
      assert_equal expected, Template.parse(template).render!(assigns)
    end

    def assert_template_result_matches(expected, template, assigns = {}, message = nil)
      return assert_template_result(expected, template, assigns, message) unless expected.is_a? Regexp

      assert_match expected, Template.parse(template).render!(assigns)
    end

    def assert_match_syntax_error(match, template, registers = {})
      exception = assert_raises(Liquid::SyntaxError) {
        Template.parse(template).render(assigns)
      }
      assert_match match, exception.message
    end

    def with_global_filter(*globals)
      original_filters = Array.new(Liquid::Strainer.class_variable_get(:@@filters))
      globals.each do |global|
        Liquid::Template.register_filter(global)
      end
      yield
    ensure
      Liquid::Strainer.class_variable_set(:@@filters, original_filters)
    end

    def with_taint_mode(mode)
      old_mode = Liquid::Template.taint_mode
      Liquid::Template.taint_mode = mode
      yield
    ensure
      Liquid::Template.taint_mode = old_mode
    end

    def with_error_mode(mode)
      old_mode = Liquid::Template.error_mode
      Liquid::Template.error_mode = mode
      yield
    ensure
      Liquid::Template.error_mode = old_mode
    end
  end
end

class ThingWithToLiquid
  def to_liquid
    'foobar'
  end
end
