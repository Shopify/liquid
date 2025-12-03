# frozen_string_literal: true

require "benchmark/ips"

# benchmark liquid lexing

require 'liquid'

RubyVM::YJIT.enable if defined?(RubyVM::YJIT)

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
  ss = StringScanner.new('')

  x.report("Liquid::Lexer#tokenize") do
    EXPRESSIONS.each do |expr|
      ss.string = expr
      Liquid::Lexer.tokenize(ss)
    end
  end

  x.compare!
end
