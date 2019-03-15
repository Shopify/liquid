source 'https://rubygems.org'
git_source(:github) do |repo_name|
  "https://github.com/#{repo_name}.git"
end

gemspec

gem 'stackprof', platforms: :mri

group :benchmark, :test do
  gem 'benchmark-ips'
end

group :test do
  gem 'rubocop', '~> 0.49.0'

  platform :mri do
    gem 'liquid-c', github: 'Shopify/liquid-c', ref: 'liquid-tag'
  end
end
