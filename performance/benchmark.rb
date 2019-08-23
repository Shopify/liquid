require 'bundler/setup'
require 'benchmark/ips'
require_relative 'theme_runner'

Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first
profiler = ThemeRunner.new

Benchmark.ips do |x|
  x.time = 60
  x.warmup = 1

  puts
  puts "Running benchmark for #{x.time} seconds (with #{x.warmup} seconds warmup)."
  puts

  profiler.compile
  # x.report("parse:") { profiler.compile }
  x.report("render:") { profiler.render }
  x.report("parse & render:") { profiler.run }
end
