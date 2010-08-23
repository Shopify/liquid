#!/usr/bin/env ruby
extras_path = File.join File.dirname(__FILE__), 'extra'
$LOAD_PATH.unshift(extras_path) unless $LOAD_PATH.include? extras_path

require 'rubygems' unless RUBY_VERSION =~ /^(?:1.9.*)$/
require 'test/unit'
require 'test/unit/assertions'
require 'caller'
require 'breakpoint'
require 'ruby-debug'
require File.join File.dirname(__FILE__), '..', 'lib', 'liquid'


module Test

  module Unit

    module Assertions
      include Liquid

      def assert_template_result(expected, template, assigns = {}, message = nil)
        assert_equal expected, Template.parse(template).render(assigns)
      end

      def assert_template_result_matches(expected, template, assigns = {}, message = nil)
        return assert_template_result(expected, template, assigns, message) unless expected.is_a? Regexp

        assert_match expected, Template.parse(template).render(assigns)
      end
    end # Assertions

  end # Unit

end # Test
