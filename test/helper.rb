#!/usr/bin/env ruby
extras_path = File.join File.dirname(__FILE__), 'extra'
$LOAD_PATH.unshift(extras_path) unless $LOAD_PATH.include? extras_path

require 'test/unit'
require 'test/unit/assertions'
require 'caller'
require 'breakpoint'
require File.dirname(__FILE__) + '/../lib/liquid'


module Test
  module Unit
    module Assertions
        include Liquid
        def assert_template_result(expected, template, assigns={}, message=nil)
          assert_equal expected, Template.parse(template).render(assigns)
        end 
    end
  end
end