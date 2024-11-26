# frozen_string_literal: true

require 'benchmark/ips'
require_relative 'theme_runner'

RubyVM::YJIT.enable if defined?(RubyVM::YJIT)
Liquid::Environment.default.error_mode = ARGV.first.to_sym if ARGV.first

profiler = ThemeRunner.new

Benchmark.ips do |x|
  x.time   = 20
  x.warmup = 10

  puts
  puts "Running benchmark for #{x.time} seconds (with #{x.warmup} seconds warmup)."
  puts

  phase = ENV["PHASE"] || "all"

  x.report("tokenize:") { profiler.tokenize } if phase == "all" || phase == "tokenize"
  x.report("parse:") { profiler.compile } if phase == "all" || phase == "parse"
  x.report("render:") { profiler.render } if phase == "all" || phase == "render"
  x.report("parse & render:") { profiler.run } if phase == "all" || phase == "run"
end
