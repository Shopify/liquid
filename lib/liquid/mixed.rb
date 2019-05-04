module Liquid
  module Mixed
    def present(input)
      input.present?
    end

    def blank(input)
      input.blank?
    end
  end

  Template.register_filter(Mixed)
end
