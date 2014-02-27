# encoding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "liquid/version"

Gem::Specification.new do |s|
  s.name        = "liquid"
  s.version     = Liquid::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "A secure, non-evaling end user template engine with aesthetic markup."
  s.authors     = ["Tobias Luetke"]
  s.email       = ["tobi@leetsoft.com"]
  s.homepage    = "http://www.liquidmarkup.org"
  s.license     = "MIT"
  #s.description = "A secure, non-evaling end user template engine with aesthetic markup."

  s.required_rubygems_version = ">= 1.3.7"

  s.test_files  = Dir.glob("{test}/**/*")
  s.files       = Dir.glob("{lib,ext}/**/*") + %w(MIT-LICENSE README.md)
  s.extensions  = ['ext/liquid/extconf.rb']

  s.extra_rdoc_files  = ["History.md", "README.md"]

  s.require_path = "lib"

  s.add_development_dependency 'rake-compiler'
  s.add_development_dependency 'stackprof'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'activesupport'
end
