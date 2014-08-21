require 'benchmark/ips'
require File.dirname(__FILE__) + '/theme_runner'

Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first
profiler = ThemeRunner.new

# This is kinda sketchy but reduces benchmark variation considerably
def with_gc_disabled (&block)
  GC.start
  GC.disable
  yield
ensure
  GC.enable
end

def run_benchmark(label, &block)
  Benchmark.ips do |x|
    # This length of time will consume 2-2.5GB of memory with GC disabled
    # Experimenting with bumping it up or down didn't seem to substantially change the times or the variation
    x.time = 10
    x.warmup = 1

    puts
    puts "Running #{label} benchmark for #{x.time} seconds (with #{x.warmup} seconds warmup)."
    puts

    x.report(label) { yield }
  end
end

with_gc_disabled do
  run_benchmark("parse:") { profiler.compile } 
end

with_gc_disabled do
  run_benchmark("parse & run:") { profiler.run } 
end
