# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) do |repo_name|
  "https://github.com/#{repo_name}.git"
end

gemspec

gem "base64"

group :benchmark, :test do
  gem 'benchmark-ips'
  gem 'memory_profiler'
  gem 'terminal-table'
  gem "lru_redux"

  install_if -> { RUBY_PLATFORM !~ /mingw|mswin|java/ && RUBY_ENGINE != 'truffleruby' } do
    gem 'stackprof'
  end
end

group :development do
  gem "webrick"
end

group :test do
  gem 'benchmark'
  gem 'rubocop', '~> 1.82.0'
  gem 'rubocop-shopify', '~> 2.18.0', require: false
  gem 'rubocop-performance', require: false
end

group :spec do
  # Includes the range resource-limit specs from https://github.com/Shopify/liquid-spec/pull/165.
  gem 'liquid-spec', github: 'Shopify/liquid-spec', ref: '84bf25e0edbca5f7e530574788b0f875ab331f50'
  gem 'activesupport', require: false
end
