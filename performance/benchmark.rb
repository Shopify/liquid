require 'benchmark/ips'
require File.dirname(__FILE__) + '/theme_runner'

Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first
profiler = ThemeRunner.new

Benchmark.ips do |x|
  x.time = 60
  x.warmup = 5

  puts
  puts "Running benchmark for #{x.time} seconds (with #{x.warmup} seconds warmup)."
  puts

  x.report("parse:") { profiler.compile }
  x.report("parse & run:") { profiler.run }
end
