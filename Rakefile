# frozen_string_literal: true

require 'rake'
require 'rake/testtask'
$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
require "liquid/version"

template_recorder_test = "test/integration/template_recorder_test.rb"

task(default: [:test, :rubocop])

desc('run test suite with default parser')
Rake::TestTask.new(:base_test) do |t|
  t.libs << 'lib' << 'test'
  test_files = FileList['test/{integration,unit}/**/*_test.rb']
  test_files.exclude(template_recorder_test) unless ENV["LIQUID_TEMPLATE_RECORDER_HOOKS"]
  t.test_files = test_files
  t.verbose    = false
end

Rake::TestTask.new(:integration_test) do |t|
  t.libs << 'lib' << 'test'
  test_files = FileList['test/integration/**/*_test.rb']
  test_files.exclude(template_recorder_test) unless ENV["LIQUID_TEMPLATE_RECORDER_HOOKS"]
  t.test_files = test_files
  t.verbose    = false
end

desc('run template recorder tests with hooks enabled')
task :template_recorder_test do
  sh(
    {
      "LIQUID_PARSER_MODE" => "lax",
      "LIQUID_TEMPLATE_RECORDER_HOOKS" => "1",
    },
    "bundle",
    "exec",
    "ruby",
    "-Itest",
    template_recorder_test,
  )
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

desc('runs test suite with lax, strict, and strict2 parsers')
task :test do
  ENV['LIQUID_PARSER_MODE'] = 'lax'
  Rake::Task['base_test'].invoke

  ENV['LIQUID_PARSER_MODE'] = 'strict'
  Rake::Task['base_test'].reenable
  Rake::Task['base_test'].invoke

  ENV['LIQUID_PARSER_MODE'] = 'strict2'
  Rake::Task['base_test'].reenable
  Rake::Task['base_test'].invoke

  if RUBY_ENGINE == 'ruby' || RUBY_ENGINE == 'truffleruby'
    ENV['LIQUID_PARSER_MODE'] = 'lax'
    Rake::Task['integration_test'].reenable
    Rake::Task['integration_test'].invoke

    ENV['LIQUID_PARSER_MODE'] = 'strict'
    Rake::Task['integration_test'].reenable
    Rake::Task['integration_test'].invoke

    ENV['LIQUID_PARSER_MODE'] = 'strict2'
    Rake::Task['integration_test'].reenable
    Rake::Task['integration_test'].invoke
  end

  Rake::Task['template_recorder_test'].invoke unless ENV["LIQUID_TEMPLATE_RECORDER_HOOKS"]
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
  task :lax do
    ruby "./performance/benchmark.rb lax"
  end

  desc "Run the liquid benchmark with strict parsing"
  task :strict do
    ruby "./performance/benchmark.rb strict"
  end

  desc "Run the liquid benchmark with strict2 parsing"
  task :strict2 do
    ruby "./performance/benchmark.rb strict2"
  end

  desc "Run the liquid benchmark with lax, strict, and strict2 parsing"
  task run: [:lax, :strict, :strict2]

  desc "Run unit benchmarks"
  namespace :unit do
    task :all do
      Dir["./performance/unit/*_benchmark.rb"].each do |file|
        puts "🧪 Running #{file}"
        ruby file
      end
    end

    task :lexer do
      Dir["./performance/unit/lexer_benchmark.rb"].each do |file|
        puts "🧪 Running #{file}"
        ruby file
      end
    end

    task :expression do
      Dir["./performance/unit/expression_benchmark.rb"].each do |file|
        puts "🧪 Running #{file}"
        ruby file
      end
    end
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

desc('run liquid-spec suite across all adapters')
task :spec do
  Dir['./spec/*.rb'].sort.each do |adapter|
    puts "=== Running #{adapter} ==="
    sh 'bundle', 'exec', 'liquid-spec', 'run', adapter, '--no-max-failures'
  end
end
