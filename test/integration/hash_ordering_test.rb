require 'test_helper'

module MoneyFilter
  def money(input)
    sprintf(' %d$ ', input)
  end
end

module CanadianMoneyFilter
  def money(input)
    sprintf(' %d$ CAD ', input)
  end
end

class HashOrderingTest < Minitest::Test
  include Liquid

  def test_global_register_order
    original_filters = Array.new(Strainer.class_eval('@@filters'))
    Template.register_filter(MoneyFilter)
    Template.register_filter(CanadianMoneyFilter)

    assert_equal " 1000$ CAD ", Template.parse("{{1000 | money}}").render(nil, nil)
  ensure
    Strainer.class_eval('@@filters = ' + original_filters.to_s)
  end

end
