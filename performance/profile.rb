require 'stackprof' rescue fail("install stackprof extension/gem")
require File.dirname(__FILE__) + '/theme_runner'

profiler = ThemeRunner.new
profiler.run
results = StackProf.run(mode: :cpu) do
  100.times do
    profiler.run
  end
end
StackProf::Report.new(results).print_text(false, 20)
File.write(ENV['FILENAME'], Marshal.dump(results)) if ENV['FILENAME']
