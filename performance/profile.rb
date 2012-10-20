require 'rubygems'
require 'ruby-prof' rescue fail("install ruby-prof extension/gem")
require File.dirname(__FILE__) + '/theme_runner'

profiler = ThemeRunner.new

puts 'Running profiler...'

results  = profiler.run

puts 'Success'
puts

[RubyProf::FlatPrinter, RubyProf::GraphPrinter, RubyProf::GraphHtmlPrinter, RubyProf::CallTreePrinter].each do |klass|
  filename = (ENV['TMP'] || '/tmp') + (klass.name.include?('Html') ? "/liquid.#{klass.name.downcase}.html" : "/callgrind.liquid.#{klass.name.downcase}.txt")
  filename.gsub!(/:+/, '_')
  File.open(filename, "w+") { |fp| klass.new(results).print(fp, :print_file => true) }
  $stderr.puts "wrote #{klass.name} output to #{filename}"
end
