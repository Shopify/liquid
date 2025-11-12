# frozen_string_literal: true

require 'stackprof'
require 'fileutils'
require_relative 'theme_runner'

output_dir = ENV['OUTPUT_DIR'] || "/tmp/liquid-performance"
FileUtils.mkdir_p(output_dir)

Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first
profiler = ThemeRunner.new
profiler.run_all # warmup

[:cpu, :object].each do |mode|
  puts
  puts "Profiling in #{mode} mode..."
  puts "writing to #{output_dir}/#{mode}.profile:"
  puts
  StackProf.run(mode: mode, raw: true, out: "#{output_dir}/#{mode}.profile") do
    200.times do
      profiler.run_all
    end
  end

  result = StackProf.run(mode: mode) do
    100.times do
      profiler.run_all
    end
  end

  StackProf::Report.new(result).print_text(false, 30)
end

puts
puts "files in #{output_dir}:"
Dir.glob("#{output_dir}/*").each do |file|
  puts "  #{file}"
end
puts "Recommended:"
puts "  stackprof --d3-flamegraph #{output_dir}/cpu.profile > #{output_dir}/flame.html"
puts "  stackprof --method #{output_dir}/cpu.profile"
puts "  etc"
