module Liquid
  class Tag
    attr_accessor :nodelist, :options

    def self.new_with_options(tag_name, markup, tokens, options)
      new_tag = self.allocate
      new_tag.options = options
      new_tag.send(:initialize, tag_name, markup, tokens)
      new_tag
    end

    def initialize(tag_name, markup, tokens)
      @tag_name   = tag_name
      @markup     = markup
      @options    ||= {} # needs || because might be set before initialize
      parse(tokens)
    end

    def parse(tokens)
    end

    def name
      self.class.name.downcase
    end

    def render(context)
      ''
    end

    def blank?
      @blank || true
    end

    def switch_parse(markup)
      case @options[:error_mode] || Template.error_mode
      when :strict then strict_parse(markup)
      when :lax    then lax_parse(markup)
      when :warn
        begin
          return strict_parse(markup)
        rescue SyntaxError => e
          @warnings ||= []
          @warnings << e
          return lax_parse(markup)
        end
      end
    end
  end # Tag
end # Liquid
