source 'https://rubygems.org'

gemspec
gem 'stackprof', platforms: :mri_21

group :test do
  gem 'spy', '0.4.1'
  gem 'benchmark-ips'
  gem 'rubocop', '>=0.32.0'

  platform :mri do
    gem 'liquid-c', github: 'Shopify/liquid-c', ref: '11d38237d9f491588a58c83dc3d364a7d0d1d55b'
  end
end
