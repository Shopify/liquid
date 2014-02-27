require 'stackprof' rescue fail("install stackprof extension/gem")
require File.dirname(__FILE__) + '/theme_runner'

profiler = ThemeRunner.new
profiler.run
results = StackProf.run(mode: :cpu, out: ENV['FILENAME']) do
  100.times do
    profiler.run
  end
end
if results.kind_of?(File)
  puts "wrote stackprof dump to #{results.path}"
else
  StackProf::Report.new(results).print_text(false, 20)
end
