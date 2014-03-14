module Liquid
  class Tag
    attr_accessor :options
    attr_reader :nodelist, :warnings

    def self.new_with_options(tag_name, markup, tokens, options)
      # Forgive me Matz for I have sinned. I know this code is weird
      # but it was necessary to maintain API compatibility.
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

    def render(context, output)
    end

    def blank?
      @blank || false
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
  end # Tag
end # Liquid
