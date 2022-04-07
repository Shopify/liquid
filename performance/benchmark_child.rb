# frozen_string_literal: true

require 'liquid'

Liquid::Template.error_mode = :strict

case ENV['ENGINE']
when 'LIQUID_COMPILE'
  require_relative '../lib/liquid/compile'
when 'LIQUID_C'
  require 'liquid/c'
when 'LIQUID_RUBY'
else
  raise "Invalid engine: #{ENV['ENGINE'].inspect}"
end

OPTIONS = {
  render_iters: 1000
}

def get_time_us
  Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
end

def render_row(charts)
  charts.map do |chart|
    io = StringIO.new
    chart.render(io)
    puts io
  end
end

Benchmarks = Class.new do
  def initialize
    @by_name = {}
  end

  def define(name, benchmark)
    @by_name[name] = benchmark
  end

  def run
    times = {}
    @by_name.each do |name, benchmark|
      benchmark.compile

      times[name] = OPTIONS[:render_iters].times.map do
        before = get_time_us
        benchmark.render
        get_time_us - before
      end
    end

    puts times.keys.join("\t")
    cols = times.values
    OPTIONS[:render_iters].times do |i|
      cols.each do |values|
        print values[i]
        print "\t" unless values == cols.last
      end
      puts
    end
  end
end.new

Dir[__dir__ + "/benchmarks/*.rb", base: __dir__].each do |path|
  require_relative path
end

Benchmarks.run