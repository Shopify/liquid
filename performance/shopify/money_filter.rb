module MoneyFilter
  
  def money_with_currency(money)
    return '' if money.nil?
    sprintf("$ %.2f USD", money/100.0)
  end

  def money(money)
    return '' if money.nil?
    sprintf("$ %.2f", money/100.0)
  end
  
  private 
  
  def currency
    ShopDrop.new.currency
  end  
end