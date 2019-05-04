module Liquid
  module Number
    def precision(input, *args)
      sigdigs = args[0] || 2
      sprintf("%.#{sigdigs}f", input.to_s.gsub(/[^0-9.]/, ''))
    end

    def ordinalize(input)
      input.ordinalize
    end

    # Given a number/float/string, convert it to a comma-separate, two-decimal-
    # place number. Make sure to maintain any currency symbols as well.
    # e.g. "$-250100" => "$-250,100.00"; 1234.5 => "1,234.50"
    # @param [Mixed] input - the value to filter.
    # @return [String] the money-fied result.
    def money(input)
      input = input.to_s.delete(',')


      if input !~ /\.\d{1,2}\z/  # if we don't have decimal places, add them.
        input += '.00'
      elsif input =~ /\.\d{1}\z/ # if we only have one, pad to two.
        input += '0'
      end

      # if first character is non-numeric, it is a currency symbol. keep it.
      currency = if input[0] !~ /\d/
        input.slice!(0, 1)
      else
        ''
      end

      # lookahead every 3 numbers and replace the number after that.
      matcher = /(\d)(?=(?:\d{3})+(?:[^\d]{1}|$))/

      currency + input.gsub(matcher, '\1,')
    end
  end

  Template.register_filter(Number)
end
