#!/usr/bin/env ruby
# frozen_string_literal: true

ENV["MT_NO_EXPECTATIONS"] = "1"
require 'minitest/autorun'

$LOAD_PATH.unshift(File.join(File.expand_path(__dir__), '..', 'lib'))
require 'liquid.rb'
require 'liquid/profiler'

mode = :strict
if (env_mode = ENV['LIQUID_PARSER_MODE'])
  puts "-- #{env_mode.upcase} ERROR MODE"
  mode = env_mode.to_sym
end
Liquid::Template.error_mode = mode

if ENV['LIQUID_C'] == '1'
  puts "-- LIQUID C"
  require 'liquid/c'
end

if Minitest.const_defined?('Test')
  # We're on Minitest 5+. Nothing to do here.
else
  # Minitest 4 doesn't have Minitest::Test yet.
  Minitest::Test = MiniTest::Unit::TestCase
end

module Minitest
  class Test
    def fixture(name)
      File.join(File.expand_path(__dir__), "fixtures", name)
    end
  end

  module Assertions
    include Liquid

    def assert_template_result(expected, template, assigns = {}, message = nil)
      assert_equal(expected, Template.parse(template, line_numbers: true).render!(assigns), message)
    end

    def assert_template_result_matches(expected, template, assigns = {}, message = nil)
      return assert_template_result(expected, template, assigns, message) unless expected.is_a?(Regexp)

      assert_match(expected, Template.parse(template, line_numbers: true).render!(assigns), message)
    end

    def assert_match_syntax_error(match, template, assigns = {})
      exception = assert_raises(Liquid::SyntaxError) do
        Template.parse(template, line_numbers: true).render(assigns)
      end
      assert_match(match, exception.message)
    end

    def assert_usage_increment(name, times: 1)
      old_method = Liquid::Usage.method(:increment)
      calls = 0
      begin
        Liquid::Usage.singleton_class.send(:remove_method, :increment)
        Liquid::Usage.define_singleton_method(:increment) do |got_name|
          calls += 1 if got_name == name
          old_method.call(got_name)
        end
        yield
      ensure
        Liquid::Usage.singleton_class.send(:remove_method, :increment)
        Liquid::Usage.define_singleton_method(:increment, old_method)
      end
      assert_equal(times, calls, "Number of calls to Usage.increment with #{name.inspect}")
    end

    def with_global_filter(*globals)
      original_global_cache = Liquid::StrainerFactory::GlobalCache
      Liquid::StrainerFactory.send(:remove_const, :GlobalCache)
      Liquid::StrainerFactory.const_set(:GlobalCache, Class.new(Liquid::StrainerTemplate))

      globals.each do |global|
        Liquid::Template.register_filter(global)
      end
      Liquid::StrainerFactory.send(:strainer_class_cache).clear
      begin
        yield
      ensure
        Liquid::StrainerFactory.send(:remove_const, :GlobalCache)
        Liquid::StrainerFactory.const_set(:GlobalCache, original_global_cache)
        Liquid::StrainerFactory.send(:strainer_class_cache).clear
      end
    end

    def with_error_mode(mode)
      old_mode = Liquid::Template.error_mode
      Liquid::Template.error_mode = mode
      yield
    ensure
      Liquid::Template.error_mode = old_mode
    end

    def with_custom_tag(tag_name, tag_class)
      old_tag = Liquid::Template.tags[tag_name]
      begin
        Liquid::Template.register_tag(tag_name, tag_class)
        yield
      ensure
        if old_tag
          Liquid::Template.tags[tag_name] = old_tag
        else
          Liquid::Template.tags.delete(tag_name)
        end
      end
    end
  end
end

class ThingWithToLiquid
  def to_liquid
    'foobar'
  end
end

class IntegerDrop < Liquid::Drop
  def initialize(value)
    super()
    @value = value.to_i
  end

  def ==(other)
    @value == other
  end

  def to_s
    @value.to_s
  end

  def to_liquid_value
    @value
  end
end

class BooleanDrop < Liquid::Drop
  def initialize(value)
    super()
    @value = value
  end

  def ==(other)
    @value == other
  end

  def to_liquid_value
    @value
  end

  def to_s
    @value ? "Yay" : "Nay"
  end
end

class ErrorDrop < Liquid::Drop
  def standard_error
    raise Liquid::StandardError, 'standard error'
  end

  def argument_error
    raise Liquid::ArgumentError, 'argument error'
  end

  def syntax_error
    raise Liquid::SyntaxError, 'syntax error'
  end

  def runtime_error
    raise 'runtime error'
  end

  def exception
    raise Exception, 'exception'
  end
end

class StubFileSystem
  attr_reader :file_read_count

  def initialize(values)
    @file_read_count = 0
    @values          = values
  end

  def read_template_file(template_path)
    @file_read_count += 1
    @values.fetch(template_path)
  end
end

class StubTemplateFactory
  attr_reader :count

  def initialize
    @count = 0
  end

  def for(_template_name)
    @count += 1
    Liquid::Template.new
  end
end
