module Liquid
  class Token < String
    attr_reader :line_number, :column_number

    def initialize(content, line_number, column_number=nil)
      super(content)
      @line_number = line_number
      @column_number = column_number
    end

    def raw
      "<raw>"
    end

    def child(string)
      Token.new(string, @line_number)
    end
  end
end
