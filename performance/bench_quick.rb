# frozen_string_literal: true

# Quick benchmark for autoresearch: measures parse µs, render µs, and object allocations
# Outputs machine-readable metrics to stdout

require_relative 'theme_runner'

RubyVM::YJIT.enable if defined?(RubyVM::YJIT)

runner = ThemeRunner.new

# Warmup — enough iterations for YJIT to fully optimize hot paths
20.times { runner.compile }
20.times { runner.render }

GC.start
GC.compact if GC.respond_to?(:compact)

# Measure parse
parse_times = []
10.times do
  GC.disable
  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  runner.compile
  t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  GC.enable
  GC.start
  parse_times << (t1 - t0) * 1_000_000 # µs
end

# Measure render
render_times = []
10.times do
  GC.disable
  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  runner.render
  t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  GC.enable
  GC.start
  render_times << (t1 - t0) * 1_000_000 # µs
end

# Measure object allocations for one parse+render cycle
require 'objspace'
GC.start
GC.disable
before = ObjectSpace.count_objects.values_at(:TOTAL).first - ObjectSpace.count_objects.values_at(:FREE).first
runner.compile
runner.render
after = ObjectSpace.count_objects.values_at(:TOTAL).first - ObjectSpace.count_objects.values_at(:FREE).first
GC.enable
allocations = after - before

parse_us = parse_times.min.round(0)
render_us = render_times.min.round(0)
combined_us = parse_us + render_us

puts "RESULTS"
puts "parse_us=#{parse_us}"
puts "render_us=#{render_us}"
puts "combined_us=#{combined_us}"
puts "allocations=#{allocations}"
