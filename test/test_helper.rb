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
Liquid::Environment.default.error_mode = mode

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

    def assert_template_result(
      expected, template, assigns = {},
      message: nil, partials: nil, error_mode: nil, render_errors: false,
      template_factory: nil
    )
      file_system = StubFileSystem.new(partials || {})
      environment = Liquid::Environment.build(file_system: file_system)
      template = Liquid::Template.parse(template, line_numbers: true, error_mode: error_mode&.to_sym, environment: environment)
      registers = Liquid::Registers.new(file_system: file_system, template_factory: template_factory)
      context = Liquid::Context.build(static_environments: assigns, rethrow_errors: !render_errors, registers: registers, environment: environment)
      output = template.render(context)
      assert_equal(expected, output, message)
    end

    def assert_match_syntax_error(match, template, error_mode: nil)
      exception = assert_raises(Liquid::SyntaxError) do
        Template.parse(template, line_numbers: true, error_mode: error_mode&.to_sym).render
      end
      assert_match(match, exception.message)
    end

    def assert_syntax_error(template, error_mode: nil)
      assert_match_syntax_error("", template, error_mode: error_mode)
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

    def with_global_filter(*globals, &blk)
      environment = Liquid::Environment.build do |w|
        w.register_filters(globals)
      end

      Environment.dangerously_override(environment, &blk)
    end

    def with_error_mode(mode)
      old_mode = Liquid::Environment.default.error_mode
      Liquid::Environment.default.error_mode = mode
      yield
    ensure
      Liquid::Environment.default.error_mode = old_mode
    end

    def with_custom_tag(tag_name, tag_class, &block)
      environment = Liquid::Environment.default.dup
      environment.register_tag(tag_name, tag_class)

      Environment.dangerously_override(environment, &block)
    end
  end
end

class ThingWithToLiquid
  def to_liquid
    'foobar'
  end
end

class SettingsDrop < Liquid::Drop
  def initialize(settings)
    super()
    @settings = settings
  end

  def liquid_method_missing(key)
    @settings[key]
  end
end

class IntegerDrop < Liquid::Drop
  def initialize(value)
    super()
    @value = value.to_i
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

  def to_liquid_value
    @value
  end

  def to_s
    @value ? "Yay" : "Nay"
  end
end

class StringDrop < Liquid::Drop
  include Comparable

  def initialize(value)
    super()
    @value = value
  end

  def to_liquid_value
    @value
  end

  def to_s
    @value
  end

  def to_str
    @value
  end

  def inspect
    "#<StringDrop @value=#{@value.inspect}>"
  end

  def <=>(other)
    to_liquid_value <=> Liquid::Utils.to_liquid_value(other)
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

  def for(template_name)
    @count += 1
    template = Liquid::Template.new
    template.name = "some/path/" + template_name
    template
  end
end
