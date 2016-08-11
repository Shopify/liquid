source 'https://rubygems.org'

gemspec
gem 'stackprof', platforms: :mri_21

group :test do
  gem 'spy', '0.4.1'
  gem 'benchmark-ips'
  gem 'rubocop', '0.34.2'

  platform :mri do
    gem 'liquid-c', github: 'Shopify/liquid-c', ref: '1fa04f1d3d4fdb5cc33bcc090334ab097ce2c10c'
  end
end
