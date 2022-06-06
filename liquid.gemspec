# encoding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "liquid/version"

Gem::Specification.new do |s|
  s.name        = "liquid"
  s.version     = Liquid::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "A secure, non-evaling end user template engine with aesthetic markup."
  s.authors     = ["Tobias Lütke"]
  s.email       = ["tobi@leetsoft.com"]
  s.homepage    = "http://www.liquidmarkup.org"
  s.license     = "MIT"
  # s.description = "A secure, non-evaling end user template engine with aesthetic markup."

  s.required_ruby_version     = ">= 2.7.0"
  s.required_rubygems_version = ">= 1.3.7"

  s.metadata['allowed_push_host'] = 'https://rubygems.org'

  s.files = Dir.glob("{lib}/**/*") + %w(LICENSE README.md)

  s.extra_rdoc_files = ["History.md", "README.md"]

  s.require_path = "lib"

  s.add_development_dependency('rake', '~> 13.0')
  s.add_development_dependency('minitest')
end
