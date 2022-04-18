# https://github.com/evanphx/benchmark-ips
require 'liquid'
#require 'liquid/c'
require 'benchmark/ips'

require_relative '../lib/liquid/compile'

require_relative 'shop_filter'
require_relative 'money_filter'

# Each database table is a hash
require_relative 'database'
tables = Database.tables

Liquid::Template.register_filter(MoneyFilter)
Liquid::Template.register_filter(ShopFilter)
@template = Liquid::Template.parse(File.read("product.liquid"))

context = Liquid::Context.new([tables, {}], {}, {}, false, Liquid::ResourceLimits.new(Liquid::Template.default_resource_limits))

require 'stackprof'

results = StackProf.run(raw: true, out: 'stackprof.dump') do
  500_000.times do
    @template.render(context)
  end
end

Benchmark.ips do |x|
    x.report("render") { @template.render(context) }

    # Compare the iterations per second of the various reports
    x.compare!
end
