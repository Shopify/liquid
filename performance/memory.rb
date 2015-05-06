require 'allocation_tracer' rescue fail("install allocation_tracer extension/gem")
require File.dirname(__FILE__) + '/theme_runner'

Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first
profiler = ThemeRunner.new

require 'allocation_tracer/trace'

puts "Profiling memory usage..."

200.times do
  profiler.run
end
