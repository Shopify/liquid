#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__), 'test') unless $:.include? File.join(File.dirname(__FILE__), 'test')

require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/gempackagetask'

task :default => 'test'

Rake::TestTask.new(:test) do |t|
  t.libs << '.' << 'lib' << 'test'
  t.pattern = 'test/lib/**/*_test.rb'
  t.verbose = false
end

gemspec = eval(File.read('liquid.gemspec'))
Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc "build the gem and release it to rubygems.org"
task :release => :gem do
  sh "gem push pkg/liquid-#{gemspec.version}.gem"
end

namespace :benchmark do 

  desc "Run the liquid benchmark"
  task :run do 
    ruby "performance/benchmark.rb"
  end
end


namespace :profile do

  desc "Run the liquid profile/performance coverage"
  task :run do

    ruby "performance/profile.rb"

  end

  desc "Run KCacheGrind"
  task :grind => :run  do
    system "kcachegrind /tmp/liquid.rubyprof_calltreeprinter.txt"
  end

end
