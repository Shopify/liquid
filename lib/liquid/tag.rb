module Liquid
  class Tag
    attr_accessor :options, :line_number
    attr_reader :nodelist, :warnings
    include ParserSwitching

    class << self
      def parse(tag_name, markup, tokens, options)
        tag = new(tag_name, markup, options)
        tag.parse(tokens)
        tag
      end

      private :new
    end

    def initialize(tag_name, markup, options)
      @tag_name   = tag_name
      @markup     = markup
      @options    = options
    end

    def parse(tokens)
    end

    def raw
      tag = @tag_name.strip
      markup = @markup.strip
      tag << " #{markup}" unless markup.empty?
      tag
    end

    def name
      self.class.name.downcase
    end

    def render(context)
      ''.freeze
    end

    def blank?
      false
    end

    def format
      "{% #{raw} %}"
    end
  end
end
