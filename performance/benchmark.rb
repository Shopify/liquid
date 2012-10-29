require 'rubygems'
require 'benchmark'
require File.dirname(__FILE__) + '/theme_runner'

profiler = ThemeRunner.new

Benchmark.bmbm do |x|
  x.report("parse:")   { 100.times { profiler.compile } }
  x.report("parse & run:")   { 100.times { profiler.run } }
end

