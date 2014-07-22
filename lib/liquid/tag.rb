module Liquid
  class Tag
    attr_accessor :options
    attr_reader :nodelist, :warnings

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

    def name
      self.class.name.downcase
    end

    def render(context)
      ''.freeze
    end

    def blank?
      false
    end

    def parse_with_selected_parser(markup)
      case @options[:error_mode] || Template.error_mode
      when :strict then strict_parse_with_error_context(markup)
      when :lax    then lax_parse(markup)
      when :warn
        begin
          return strict_parse_with_error_context(markup)
        rescue SyntaxError => e
          @warnings ||= []
          @warnings << e
          return lax_parse(markup)
        end
      end
    end

    private

    def strict_parse_with_error_context(markup)
      strict_parse(markup)
    rescue SyntaxError => e
      e.message << " in \"#{markup.strip}\"" 
      raise e
    end
  end
end
