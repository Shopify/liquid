require 'benchmark'
require File.dirname(__FILE__) + '/theme_runner'

Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first
profiler = ThemeRunner.new

N = 100
Benchmark.bmbm do |x|
  x.report("parse:")                 { N.times { profiler.parse } }
  x.report("marshal load:")          { N.times { profiler.marshal_load } }
  x.report("render:")                { N.times { profiler.render } }
  x.report("marshal load & render:") { N.times { profiler.load_and_render } }
  x.report("parse & render:")        { N.times { profiler.parse_and_render } }
end
