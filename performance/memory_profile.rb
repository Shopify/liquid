# frozen_string_literal: true

require 'benchmark/ips'
require 'memory_profiler'
require_relative 'theme_runner'

def profile(phase, &block)
  puts
  puts "#{phase}:"
  puts

  report = MemoryProfiler.report(&block)

  report.pretty_print(
    color_output: true,
    scale_bytes: true,
    detailed_report: true
  )
end

Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first

profiler = ThemeRunner.new

profile("Parsing") { profiler.compile }
profile("Rendering") { profiler.render }
