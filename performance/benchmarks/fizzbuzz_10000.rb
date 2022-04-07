# frozen_string_literal: true

Benchmarks.define('fizzbuzz_10000', Class.new do
  TEMPLATE = <<~LIQUID
  {% for i in (1..10000) %}{{ i }}
  {% endfor %}
  LIQUID

  def compile
    @parsed = Liquid::Template.parse(TEMPLATE)
  end

  def render
    @parsed.render
  end
end.new)