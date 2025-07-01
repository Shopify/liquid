# frozen_string_literal: true

require "benchmark/ips"

# benchmark liquid lexing

require 'liquid'

RubyVM::YJIT.enable

EXPRESSIONS = [
  "foo[1..2].baz",
  "12.0",
  "foo.bar.based",
  "21 - 62",
  "foo.bar.baz",
  "foo > 12",
  "foo < 12",
  "foo <= 12",
  "foo >= 12",
  "foo <> 12",
  "foo == 12",
  "foo != 12",
  "foo contains 12",
  "foo contains 'bar'",
  "foo != 'bar'",
  "'foo' contains 'bar'",
  '234089',
  "foo | default: -1",
]

Benchmark.ips do |x|
  x.config(time: 10, warmup: 5)

  x.report("Liquid::Lexer#tokenize") do
    EXPRESSIONS.each do |expr|
      l = Liquid::Lexer.new(expr)
      l.tokenize
    end
  end

  x.compare!
end
