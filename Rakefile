#!/usr/bin/env ruby

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'fileutils'
require 'rake/testtask'
require 'rubygems/package_task'

task :default => [:compile, :test]

task :gen do
  sh "leg -oext/liquid/liquid_context.c ext/liquid/liquid_context.leg"
end

task :compile => [:gen, :liquid_ext]

extension = "liquid_ext"
ext = "ext/liquid"
ext_so = "#{ext}/#{extension}.#{RbConfig::CONFIG['DLEXT']}"
ext_files = FileList[
  "#{ext}/*.c",
  "#{ext}/*.h",
  "#{ext}/*.leg",
  "#{ext}/extconf.rb",
  "#{ext}/Makefile",
  "lib"
]

task "lib" do
  directory "lib"
end

desc "Builds just the #{extension} extension"
task extension.to_sym => [:gen, "#{ext}/Makefile", ext_so ]

file "#{ext}/Makefile" => ["#{ext}/extconf.rb"] do
  Dir.chdir(ext) do ruby "extconf.rb" end
end

file ext_so => ext_files do
  Dir.chdir(ext) do
    sh "make"
  end
  cp ext_so, "lib"
end

Rake::TestTask.new(:test => [:gen, 'liquid_ext']) do |t|
  t.libs << '.' << 'lib' << 'test'
  t.test_files = FileList['test/liquid/**/*_test.rb']
  t.verbose = false
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

  desc "Run the liquid benchmark"
  task :run do
    ruby "./performance/benchmark.rb"
  end

end


namespace :profile do

  desc "Run the liquid profile/performance coverage"
  task :run do
    ruby "./performance/profile.rb"
  end

  desc "Run KCacheGrind"
  task :grind => :run  do
    system "qcachegrind /tmp//callgrind.liquid.txt"
  end

end

desc "Run example"
task :example do
  ruby "-w -d -Ilib example/server/server.rb"
end
