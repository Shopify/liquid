require 'benchmark'
require File.dirname(__FILE__) + '/theme_runner'

Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first
profiler = ThemeRunner.new

Benchmark.bmbm do |x|
  x.report("parse:")   { 100.times { profiler.compile } }
  x.report("parse & run:")   { 100.times { profiler.run } }
end

