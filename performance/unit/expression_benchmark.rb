# frozen_string_literal: true

require "benchmark/ips"

# benchmark liquid lexing

require 'liquid'

RubyVM::YJIT.enable if defined?(RubyVM::YJIT)

STRING_MARKUPS = [
  "\"foo\"",
  "\"fooooooooooo\"",
  "\"foooooooooooooooooooooooooooooo\"",
  "'foo'",
  "'fooooooooooo'",
  "'foooooooooooooooooooooooooooooo'",
]

VARIABLE_MARKUPS = [
  "article",
  "article.title",
  "article.title.size",
  "very_long_variable_name_2024_11_05",
  "very_long_variable_name_2024_11_05.size",
]

NUMBER_MARKUPS = [
  "0",
  "35",
  "1241891024912849",
  "3.5",
  "3.51214128409128",
  "12381902839.123819283910283",
  "123.456.789",
  "-123",
  "-12.33",
  "-405.231",
  "-0",
  "0",
  "0.0",
  "0.0000000000000000000000",
  "0.00000000001",
]

RANGE_MARKUPS = [
  "(1..30)",
  "(1..foo)",
  "(foo..30)",
  "(foo..bar)",
]

LITERAL_MARKUPS = [
  'nil',
  'null',
  'true',
  'false',
  'blank',
  'empty',
]

MARKUPS = {
  "string" => STRING_MARKUPS,
  "literal" => LITERAL_MARKUPS,
  "variable" => VARIABLE_MARKUPS,
  "number" => NUMBER_MARKUPS,
  "range" => RANGE_MARKUPS,
}

module Liquid
  Benchmark.ips do |x|
    x.config(time: 5, warmup: 5)

    ss = StringScanner.new('')

    MARKUPS.each do |type, markups|
      x.report("#{type} - Liquid::Expression#parse") do
        markups.each do |markup|
          ss.string = markup
          Expression.parse(markup, ss)
        end
      end

      x.report("#{type} - Liquid::Parser#expression") do
        markups.each do |markup|
          ss.string = markup
          Parser.new(ss).expression
        end
      end

      x.report("#{type} - Liquid::Expression.parse(Parser#expression_string)") do
        markups.each do |markup|
          ss.string = markup
          Expression.parse(Parser.new(ss).expression_string, ss)
        end
      end
    end

    x.report("Liquid::Expression#parse: all") do
      MARKUPS.values.flatten.each do |markup|
        Expression.parse(markup)
      end
    end
  end
end
