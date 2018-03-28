module Liquid
  module String
    def titleize(input)
      input.titleize
    end

    def pluralize(num, singular, plural)
      num == 1 ? singular : plural
    end
  end

  Template.register_filter(String)
end
