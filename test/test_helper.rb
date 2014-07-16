#!/usr/bin/env ruby

require 'test/unit'
require 'test/unit/assertions'
require 'spy/integration'

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib'))
require 'liquid.rb'

mode = :strict
if env_mode = ENV['LIQUID_PARSER_MODE']
  puts "-- #{env_mode.upcase} ERROR MODE"
  mode = env_mode.to_sym
end
Liquid::Template.error_mode = mode


module Test
  module Unit
    class TestCase
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
        exception = assert_raise(Liquid::SyntaxError) {
          Template.parse(template).render(assigns)
        }
        assert_match match, exception.message
      end

      def with_error_mode(mode)
        old_mode = Liquid::Template.error_mode
        Liquid::Template.error_mode = mode
        yield
        Liquid::Template.error_mode = old_mode
      end
    end # Assertions
  end # Unit
end # Test
