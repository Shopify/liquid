# frozen_string_literal: true

module WeightFilter
  def weight(grams)
    format("%.2f", grams / 1000)
  end

  def weight_with_unit(grams)
    "#{weight(grams)} kg"
  end
end
