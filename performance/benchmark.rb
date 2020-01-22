require 'benchmark/ips'
require_relative 'theme_runner'

case ARGV.first.to_sym
when :lax
  Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first
when :strict
  Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first
when :superfluid
  require 'liquid/superfluid'
  Liquid::Template.error_mode = :strict
end

profiler = ThemeRunner.new

Benchmark.ips do |x|
  x.time = 10
  x.warmup = 5

  puts
  puts "Running benchmark for #{x.time} seconds (with #{x.warmup} seconds warmup)."
  puts

  x.report("parse:") { profiler.compile }
  x.report("render:") { profiler.render }
  x.report("parse & render:") { profiler.run }
end
