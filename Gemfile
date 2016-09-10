source 'https://rubygems.org'

gemspec
gem 'stackprof', platforms: :mri_21

group :test do
  gem 'spy', '0.4.1'
  gem 'benchmark-ips'
  gem 'rubocop', '0.34.2'

  platform :mri do
    gem 'liquid-c', github: 'Shopify/liquid-c', ref: 'bd53db95de3d44d631e7c5a267c3d934e66107dd'
  end
end
