require 'rubygems'
require 'benchmark'
require File.dirname(__FILE__) + '/theme_runner'

profiler = ThemeRunner.new

Benchmark.bmbm do |x|
  x.report("parse & run:")   { 10.times { profiler.run(false) } }
end

