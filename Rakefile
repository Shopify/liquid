#!/usr/bin/env ruby
require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/gempackagetask'

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = 'test/*_test.rb'
  t.verbose = false
end

gemspec = eval(File.read('liquid.gemspec'))
Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

namespace :profile do

  
  task :default => [:run]
  
  desc "Run the liquid profile/perforamce coverage"
  task :run do
  
    ruby "performance/shopify.rb"
  
  end
  
  desc "Run KCacheGrind" 
  task :grind => :run  do
    system "kcachegrind /tmp/liquid.rubyprof_calltreeprinter.txt"
  end
end
  
  