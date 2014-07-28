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
    with_global_filter(MoneyFilter, CanadianMoneyFilter) do
      assert_equal " 1000$ CAD ", Template.parse("{{1000 | money}}").render(nil, nil)
    end
  end
end
