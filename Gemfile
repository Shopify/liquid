source 'https://rubygems.org'

gemspec

gem 'stackprof', platforms: :mri

group :benchmark, :test do
  gem 'benchmark-ips'
end

group :test do
  gem 'rubocop', '0.34.2'

  platform :mri do
    gem 'liquid-c', github: 'Shopify/liquid-c', ref: 'bd53db95de3d44d631e7c5a267c3d934e66107dd'
  end
end
