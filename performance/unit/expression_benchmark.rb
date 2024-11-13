# frozen_string_literal: true

require "benchmark/ips"

# benchmark liquid lexing

require 'liquid'

RubyVM::YJIT.enable

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
  "(1...30)",
  "(1..30..5)",
  "(1.0...30.0)",
  "(1.........30)",
  "(1..foo)",
  "(foo..30)",
  "(foo..bar)",
  "(foo...bar...100)",
  "(foo...bar...100.0)",
]

LITERAL_MARKUPS = [
  nil,
  'nil',
  'null',
  '',
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

def compare_objects(object_1, object_2)
  if object_1.is_a?(Liquid::VariableLookup) && object_2.is_a?(Liquid::VariableLookup)
    return false if object_1.name != object_2.name
  elsif object_1 != object_2
    return false
  end

  true
end

def compare_range_lookup(expression_1_result, expression_2_result)
  return false unless expression_1_result.is_a?(Liquid::RangeLookup) && expression_2_result.is_a?(Liquid::RangeLookup)

  start_obj_1 = expression_1_result.start_obj
  start_obj_2 = expression_2_result.start_obj

  return false unless compare_objects(start_obj_1, start_obj_2)

  end_obj_1 = expression_1_result.end_obj
  end_obj_2 = expression_2_result.end_obj

  return false unless compare_objects(end_obj_1, end_obj_2)

  true
end

MARKUPS.values.flatten.each do |markup|
  expression_1_result = Liquid::Expression1.parse(markup)
  expression_2_result = Liquid::Expression2.parse(markup)

  next if expression_1_result == expression_2_result

  if expression_1_result.is_a?(Liquid::RangeLookup) && expression_2_result.is_a?(Liquid::RangeLookup)
    next if compare_range_lookup(expression_1_result, expression_2_result)
  end

  warn "Expression1 and Expression2 results are different for markup: #{markup}"
  warn "expected: #{expression_1_result}"
  warn "got: #{expression_2_result}"
  abort
end

warmed_up = false

MARKUPS.each do |type, markups|
  Benchmark.ips do |x|
    if warmed_up
      x.config(time: 10, warmup: 5)
      warmed_up = true
    else
      x.config(time: 10)
    end

    x.report("Liquid::Expression1#parse: #{type}") do
      if Liquid::Expression != Liquid::Expression1
        Liquid.send(:remove_const, :Expression)
        Liquid.const_set(:Expression, Liquid::Expression1)
      end

      markups.each do |markup|
        Liquid::Expression1.parse(markup)
      end
    end

    x.report("Liquid::Expression2#parse: #{type}") do
      if Liquid::Expression != Liquid::Expression2
        Liquid.send(:remove_const, :Expression)
        Liquid.const_set(:Expression, Liquid::Expression2)
      end

      markups.each do |markup|
        Liquid::Expression2.parse(markup)
      end
    end

    x.compare!
  end
end

Benchmark.ips do |x|
  x.config(time: 10)

  x.report("Liquid::Expression1#parse: all") do
    if Liquid::Expression != Liquid::Expression1
      Liquid.send(:remove_const, :Expression)
      Liquid.const_set(:Expression, Liquid::Expression1)
    end

    MARKUPS.values.flatten.each do |markup|
      Liquid::Expression1.parse(markup)
    end
  end

  x.report("Liquid::Expression2#parse: all") do
    if Liquid::Expression != Liquid::Expression2
      Liquid.send(:remove_const, :Expression)
      Liquid.const_set(:Expression, Liquid::Expression2)
    end

    MARKUPS.values.flatten.each do |markup|
      Liquid::Expression2.parse(markup)
    end
  end

  x.compare!
end
