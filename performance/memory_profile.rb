# frozen_string_literal: true

require 'benchmark/ips'
require 'memory_profiler'
require 'terminal-table'
require_relative 'theme_runner'

class Profiler
  LOG_LABEL   = "Profiling: ".rjust(14).freeze
  REPORTS_DIR = File.expand_path('.memprof', __dir__).freeze

  def self.run
    puts
    yield new
  end

  def initialize
    @allocated = []
    @retained  = []
    @headings  = []
  end

  def profile(phase, &block)
    print(LOG_LABEL)
    print("#{phase}.. ".ljust(10))
    report = MemoryProfiler.report(&block)
    puts 'Done.'
    @headings  << phase.capitalize
    @allocated << "#{report.scale_bytes(report.total_allocated_memsize)} (#{report.total_allocated} objects)"
    @retained  << "#{report.scale_bytes(report.total_retained_memsize)} (#{report.total_retained} objects)"

    return if ENV['CI']

    require 'fileutils'
    report_file = File.join(REPORTS_DIR, "#{sanitize(phase)}.txt")
    FileUtils.mkdir_p(REPORTS_DIR)
    report.pretty_print(to_file: report_file, scale_bytes: true)
  end

  def tabulate
    table = Terminal::Table.new(headings: @headings.unshift('Phase')) do |t|
      t << @allocated.unshift('Total allocated')
      t << @retained.unshift('Total retained')
    end

    puts
    puts table
    puts "\nDetailed report(s) saved to #{REPORTS_DIR}/" unless ENV['CI']
  end

  def sanitize(string)
    string.downcase.gsub(/[\W]/, '-').squeeze('-')
  end
end

Liquid::Template.error_mode = ARGV.first.to_sym if ARGV.first

runner = ThemeRunner.new
Profiler.run do |x|
  x.profile('parse') { runner.compile }
  x.profile('render') { runner.render }
  x.tabulate
end
