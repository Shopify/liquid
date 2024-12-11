# frozen_string_literal: true

require "benchmark/ips"
require 'liquid'

RubyVM::YJIT.enable

TEMPLATE = <<~LIQUID
{% if false %}
  {% for i in (1..1000000) %}
    {{ "Hello world!" }}
  {% endfor %}
{% endif %}

{% assign result = 1 %}
{% if foo == 1 %}{% assign result = 1 %}{% endif %}{% if foo == 2 %}{% assign result = 2 %}{% endif %}{% if foo == 3 %}{% assign result = 3 %}{% endif %}
Result: {{ result }}
LIQUID

baseline_template = Liquid::Template.parse(TEMPLATE, eager_optimize: false)
optimized_template = Liquid::Template.parse(TEMPLATE, eager_optimize: true)

[nil, 1, 2, 3].each do |foo|
  baseline_output = baseline_template.render('foo' => foo)
  optimized_output = optimized_template.render('foo' => foo)

  if baseline_output != optimized_output
    puts "WARNING! Baseline and optimized templates render differently for foo=#{foo}"
    puts "Baseline: #{baseline_output}"
    puts "Optimized: #{optimized_output}"

    raise
  end
end

def render(template, foo)
  template.render('foo' => foo)
end

Benchmark.ips do |x|
  x.config(time: 20, warmup: 3)

  x.report("baseline") do
    [nil, 1, 2, 3].each do |foo|
      render(baseline_template, foo)
    end
  end

  x.report("optimized") do
    [nil, 1, 2, 3].each do |foo|
      render(optimized_template, foo)
    end
  end

  x.compare!
end
