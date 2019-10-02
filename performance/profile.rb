# frozen_string_literal: true

require 'stackprof'
require_relative 'theme_runner'

Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first
profiler = ThemeRunner.new
profiler.run

[:cpu, :object].each do |profile_type|
  puts "Profiling in #{profile_type} mode..."
  results = StackProf.run(mode: profile_type) do
    200.times do
      profiler.run
    end
  end

  if profile_type == :cpu && (graph_filename = ENV['GRAPH_FILENAME'])
    File.open(graph_filename, 'w') do |f|
      StackProf::Report.new(results).print_graphviz(nil, f)
    end
  end

  StackProf::Report.new(results).print_text(false, 20)
  File.write(ENV['FILENAME'] + "." + profile_type.to_s, Marshal.dump(results)) if ENV['FILENAME']
end
