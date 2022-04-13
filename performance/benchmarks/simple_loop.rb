# frozen_string_literal: true

Benchmarks.define('simple_loop', Class.new do
  TEMPLATE = "{% for i in (1..1000) %}{{ i }}{% endfor %}"

  def compile
    @parsed = Liquid::Template.parse(TEMPLATE)
  end

  def render
    @parsed.render
  end
end.new)