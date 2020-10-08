# frozen_string_literal: true

require 'rake'
require 'rake/testtask'
$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
require "liquid/version"

task(default: [:test, :rubocop])

desc('run test suite with default parser')
Rake::TestTask.new(:base_test) do |t|
  t.libs << 'lib' << 'test'
  t.test_files = FileList['test/{integration,unit}/**/*_test.rb']
  t.verbose    = false
end

Rake::TestTask.new(:integration_test) do |t|
  t.libs << 'lib' << 'test'
  t.test_files = FileList['test/integration/**/*_test.rb']
  t.verbose    = false
end

desc('run test suite with warn error mode')
task :warn_test do
  ENV['LIQUID_PARSER_MODE'] = 'warn'
  Rake::Task['base_test'].invoke
end

task :rubocop do
  if RUBY_ENGINE == 'ruby'
    require 'rubocop/rake_task'
    RuboCop::RakeTask.new
  end
end

desc('runs test suite with both strict and lax parsers')
task :test do
  ENV['LIQUID_PARSER_MODE'] = 'lax'
  Rake::Task['base_test'].invoke

  ENV['LIQUID_PARSER_MODE'] = 'strict'
  Rake::Task['base_test'].reenable
  Rake::Task['base_test'].invoke

  if RUBY_ENGINE == 'ruby' || RUBY_ENGINE == 'truffleruby'
    ENV['LIQUID_C'] = '1'

    ENV['LIQUID_PARSER_MODE'] = 'lax'
    Rake::Task['integration_test'].reenable
    Rake::Task['integration_test'].invoke

    ENV['LIQUID_PARSER_MODE'] = 'strict'
    Rake::Task['integration_test'].reenable
    Rake::Task['integration_test'].invoke
  end
end

task(gem: :build)
task :build do
  system "gem build liquid.gemspec"
end

task install: :build do
  system "gem install liquid-#{Liquid::VERSION}.gem"
end

task release: :build do
  system "git tag -a v#{Liquid::VERSION} -m 'Tagging #{Liquid::VERSION}'"
  system "git push --tags"
  system "gem push liquid-#{Liquid::VERSION}.gem"
  system "rm liquid-#{Liquid::VERSION}.gem"
end

namespace :benchmark do
  desc "Run the liquid benchmark with lax parsing"
  task :run do
    ruby "./performance/benchmark.rb lax"
  end

  desc "Run the liquid benchmark with strict parsing"
  task :strict do
    ruby "./performance/benchmark.rb strict"
  end
end

namespace :profile do
  desc "Run the liquid profile/performance coverage"
  task :run do
    ruby "./performance/profile.rb"
  end

  desc "Run the liquid profile/performance coverage with strict parsing"
  task :strict do
    ruby "./performance/profile.rb strict"
  end
end

namespace :memory_profile do
  desc "Run memory profiler"
  task :run do
    ruby "./performance/memory_profile.rb"
  end
end

desc("Run example")
task :example do
  ruby "-w -d -Ilib example/server/server.rb"
end

task :console do
  exec 'irb -I lib -r liquid'
end
