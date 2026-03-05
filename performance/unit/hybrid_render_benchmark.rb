# frozen_string_literal: true

require "benchmark/ips"

# Benchmark hybrid render tag parsing overhead.

require 'liquid'

RubyVM::YJIT.enable if defined?(RubyVM::YJIT)

# -- Templates -----------------------------------------------------------------

SINGLE_SELF_CLOSING = "{% render 'snippet' %}"

MULTIPLE_SELF_CLOSING = (1..20).map { |i| "{% render 'snippet_#{i}' %}" }.join("\n")

BLOCK_FORM = "{% render 'snippet' %}Hello, world!{% endrender %}"

MIXED_TEMPLATE = <<~LIQUID
  {% assign title = 'Hello' %}
  {% render 'header' %}
  {% for item in collection %}
    {% render 'card' %}
    <p>{{ item.title }}</p>
  {% endfor %}
  {% render 'footer' %}
LIQUID

LONG_TAIL = "{% render 'snippet' %}\n" + (1..100).map { |i| "{% assign x#{i} = #{i} %}" }.join("\n")

TEMPLATES = {
  "single self-closing render" => SINGLE_SELF_CLOSING,
  "20x consecutive self-closing renders" => MULTIPLE_SELF_CLOSING,
  "block-form render" => BLOCK_FORM,
  "mixed template (self-closing + other tags)" => MIXED_TEMPLATE,
  "self-closing render + 100 trailing tags" => LONG_TAIL,
}

# -- Benchmark -----------------------------------------------------------------

env = Liquid::Environment.default

Benchmark.ips do |x|
  x.config(time: 10, warmup: 5)

  TEMPLATES.each do |label, source|
    x.report("parse: #{label}") do
      Liquid::Template.parse(source, environment: env)
    end
  end

  x.compare!
end
