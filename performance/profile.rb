# frozen_string_literal: true

require 'stackprof'
require 'fileutils'
require_relative 'theme_runner'

output_dir = ENV['OUTPUT_DIR'] || "/tmp/liquid-performance"
FileUtils.mkdir_p(output_dir)

Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first
profiler = ThemeRunner.new
profiler.run_all # warmup

puts
puts "writing to #{output_dir}/cpu.profile"
StackProf.run(mode: :cpu, raw: true, out: "#{output_dir}/cpu.profile") do
  100.times do
    profiler.run_all
  end
end

puts "writing to #{output_dir}/object.profile"
StackProf.run(mode: :object, raw: true, out: "#{output_dir}/object.profile") do
  100.times do
    profiler.run_all
  end
end

puts "running cpu profile"
results = StackProf.run(mode: :cpu) do
  100.times do
    profiler.run_all
  end
end

File.open("#{output_dir}/cpu.graph.dot", 'w+') do |f|
  puts("Writing cpu graph to #{File.join(output_dir, "cpu.graph.dot")}")
  StackProf::Report.new(results).print_graphviz({}, f)
end

StackProf::Report.new(results).print_text(false, 20)
puts("Writing cpu profile to #{File.join(output_dir, "cpu.profile")}")
File.write(File.join(output_dir, "cpu.profile"), Marshal.dump(results))

puts
puts "Profiling in object mode..."
results = StackProf.run(mode: :object) do
  100.times do
    profiler.run_all
  end
end

File.open("#{output_dir}/object.graph.dot", 'w+') do |f|
  puts("Writing object graph to #{File.join(output_dir, "object.graph.dot")}")
  StackProf::Report.new(results).print_graphviz({}, f)
end

StackProf::Report.new(results).print_text(false, 20)
puts("Writing object profile to #{File.join(output_dir, "object.profile")}")
File.write(File.join(output_dir, "object.profile"), Marshal.dump(results))
puts
puts
puts "files in #{output_dir}:"
Dir.glob("#{output_dir}/*").each do |file|
  puts "  #{file}"
end
puts "Recommended:"
puts "stackprof --d3-flamegraph #{output_dir}/cpu.profile > #{output_dir}/flame.html"
