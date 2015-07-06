source 'https://rubygems.org'

gemspec
gem 'stackprof', platforms: :mri_21

group :test do
  gem 'spy', '0.4.1'
  gem 'benchmark-ips'
  gem 'rubocop', '>=0.32.0'

  platform :mri do
    gem 'liquid-c', github: 'Shopify/liquid-c', ref: '35e9aee48d639ae1d3ac9ba77616aca9800eab7d'
  end
end
