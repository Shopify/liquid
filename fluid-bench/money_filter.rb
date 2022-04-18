# frozen_string_literal: true

module MoneyFilter
  def money_with_currency(money)
    return '' if money.nil?
    format("$ %.2f USD", money / 100.0)
  end

  def money(money)
    return '' if money.nil?
    format("$ %.2f", money / 100.0)
  end

  private

  def currency
    ShopDrop.new.currency
  end
end
