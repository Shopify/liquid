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
  # Includes the merged specs from https://github.com/Shopify/liquid-spec/pull/144.
  gem 'liquid-spec', github: 'Shopify/liquid-spec', ref: '416a66b4cd9abf7927cf78bb1f4bf950f68b862f'
  gem 'activesupport', require: false
end
