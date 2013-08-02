#!/usr/bin/env ruby

require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rubygems/package_task'

task :default => 'test'

Rake::TestTask.new(:lax_test) do |t|
  t.libs << '.' << 'lib' << 'test'
  t.test_files = FileList['test/liquid/**/*_test.rb']
  t.options = 'lax'
  t.verbose = false
end

Rake::TestTask.new(:strict_test) do |t|
  t.libs << '.' << 'lib' << 'test'
  t.test_files = FileList['test/liquid/**/*_test.rb']
  t.verbose = false
end

desc 'runs test suite with both strict and lax parsers'
task :test do
  Rake::Task['lax_test'].invoke
  Rake::Task['strict_test'].invoke
end

gemspec = eval(File.read('liquid.gemspec'))
Gem::PackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc "Build the gem and release it to rubygems.org"
task :release => :gem do
  sh "gem push pkg/liquid-#{gemspec.version}.gem"
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

  desc "Run KCacheGrind"
  task :grind => :run  do
    system "qcachegrind /tmp/liquid.rubyprof_calltreeprinter.txt"
  end

end

desc "Run example"
task :example do
  ruby "-w -d -Ilib example/server/server.rb"
end
