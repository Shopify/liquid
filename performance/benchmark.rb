# frozen_string_literal: true

require 'benchmark/ips'
require_relative 'theme_runner'

if defined?(RubyVM::YJIT)
  RubyVM::YJIT.enable
  puts "* YJIT enabled"
else
  puts "* YJIT not enabled"
end

Liquid::Environment.default.error_mode = ARGV.first.to_sym if ARGV.first

profiler = ThemeRunner.new

Benchmark.ips do |x|
  x.time   = 20
  x.warmup = 10

  puts
  puts "Running benchmark for #{x.time} seconds (with #{x.warmup} seconds warmup)."
  puts

  phase = ENV["PHASE"] || "all"

  x.report("tokenize:") { profiler.tokenize_all } if phase == "all" || phase == "tokenize"
  x.report("parse:") { profiler.compile_all } if phase == "all" || phase == "parse"
  x.report("render:") { profiler.render_all } if phase == "all" || phase == "render"
  x.report("parse & render:") { profiler.run_all } if phase == "all" || phase == "run"
end
