# frozen_string_literal: true

Benchmarks.define('fizzbuzz_10000', Class.new do
  TEMPLATE = <<~LIQUID
  {% for i in (1..#{ENV['COUNT'].to_i}) %}
    {% liquid
      assign rem_3 = i | modulo: 3
      assign rem_5 = i | modulo: 5
      if rem_3 == 0 and rem_5 == 0
        echo "Fizzbuzz"
      elsif rem_3 == 0
        echo "Fizz"
      elsif rem_5 == 0
        echo "Buzz"
      else
        echo i
      endif
    %}{% endfor %}
  LIQUID

  def compile
    @parsed = Liquid::Template.parse(TEMPLATE)
  end

  def render
    @parsed.render
  end
end.new)