require 'utils'
module Liquid
  module Date
    def date(input, format)
      format = format.to_s
      return input if format.empty?

      if input == 'now'
        company = @context['company'] || {}
        time_zone = company['time_zone']
        return Time.current.strftime(format) unless time_zone

        Time.use_zone(time_zone) do
          Time.current.strftime(format)
        end
      else
        return input unless date = ::Utils.to_date(input)

        date.strftime(format)
      end
    end
  end

  Template.register_filter(Date)
end
