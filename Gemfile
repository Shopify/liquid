source 'https://rubygems.org'

gemspec
gem 'stackprof', platforms: :mri_21

group :test do
  gem 'spy', '0.4.1'
  gem 'benchmark-ips'
  gem 'rubocop', '0.34.2'
  gem 'byebug'

  platform :mri do
    gem 'liquid-c', github: 'Shopify/liquid-c', ref: 'e77102d2e6159418e80b4fc083d10a63b4fde9f2'
  end
end
