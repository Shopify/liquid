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

EXPRESSIONS.each do |expr|
  lexer_1_result = Liquid::Lexer1.new(expr).tokenize
  lexer_2_result = Liquid::Lexer2.new(expr).tokenize

  next if lexer_1_result == lexer_2_result

  warn "Lexer1 and Lexer2 results are different for expression: #{expr}"
  warn "expected: #{lexer_1_result}"
  warn "got: #{lexer_2_result}"
  abort
end

Benchmark.ips do |x|
  x.config(time: 10, warmup: 5)

  x.report("Liquid::Lexer1#tokenize") do
    EXPRESSIONS.each do |expr|
      l = Liquid::Lexer1.new(expr)
      l.tokenize
    end
  end

  x.report("Liquid::Lexer2#tokenize") do
    EXPRESSIONS.each do |expr|
      l = Liquid::Lexer2.new(expr)
      l.tokenize
    end
  end

  x.compare!
end
