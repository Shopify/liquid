module WeightFilter

  def weight(grams)
    sprintf("%.2f", grams / 1000)
  end
  
  def weight_with_unit(grams)
    "#{weight(grams)} kg"
  end  
  
end