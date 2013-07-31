module Liquid
  class Tag
    attr_accessor :nodelist, :options

    def self.new_with_options(tag_name, markup, tokens, options)
      # Forgive me Matz for I have sinned.
      # I have forsaken the holy idioms of Ruby and used Class#allocate.
      # I fulfilled my mandate by maintaining API compatibility and performance,
      # even though it may displease your Lordship.
      #
      # In all seriousness though, I can prove to a reasonable degree of certainty
      # that setting options before calling initialize is required to maintain API compatibility.
      # I tried doing it without it and not only did I break compatibility, it was much slower.
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
