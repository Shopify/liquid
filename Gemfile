source 'https://rubygems.org'

gemspec
gem 'stackprof', platforms: :mri_21

group :test do
  gem 'spy', '0.4.1'
  gem 'benchmark-ips'
  gem 'rubocop', '0.34.2'

  platform :mri do
    gem 'liquid-c', github: 'Shopify/liquid-c', ref: '2570693d8d03faa0df9160ec74348a7149436df3'
  end
end
