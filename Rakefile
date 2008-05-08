#!/usr/bin/env ruby
require 'rubygems'
require 'rake'
require 'hoe'

PKG_VERSION = "1.9.0"
PKG_NAME    = "liquid"
PKG_DESC    = "A secure non evaling end user template engine with aesthetic markup."

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = 'test/*_test.rb'
  t.verbose = false
end

Hoe.new(PKG_NAME, PKG_VERSION) do |p|
  p.rubyforge_name = PKG_NAME
  p.summary        = PKG_DESC
  p.description    = PKG_DESC
  p.author         = "Tobias Luetke"
  p.email          = "tobi@leetsoft.com"
  p.url            = "http://www.liquidmarkup.org"    
end