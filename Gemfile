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
    gem 'liquid-c', github: 'Shopify/liquid-c', ref: '9168659de45d6d576fce30c735f857e597fa26f6'
  end
end
