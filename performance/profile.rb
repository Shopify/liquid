require 'rubygems'
require 'ruby-prof' rescue fail("install ruby-prof extension/gem")
require File.dirname(__FILE__) + '/theme_runner'

profiler = ThemeRunner.new

puts 'Running profiler...'

results  = profiler.run_profile

puts 'Success'

filename = (ENV['TMP'] || '/tmp') + "/callgrind.liquid.txt"
File.open(filename, "w+") do |fp| 
  RubyProf::CallTreePrinter.new(results).print(fp, :print_file => true) 
end
$stderr.puts "wrote RubyProf::CallTreePrinter output to #{filename}"
