module Liquid
  module ParserSwitching
    def parse_with_selected_parser(markup)
      case @options[:error_mode] || Template.error_mode
      when :strict then strict_parse_with_error_context(markup)
      when :lax    then lax_parse(markup)
      when :warn
        begin
          return strict_parse_with_error_context(markup)
        rescue SyntaxError => e
          e.set_line_number_from_token(markup)
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
      e.markup_context = markup_context(markup)
      raise e
    end

    def markup_context(markup)
      "in \"#{markup.strip}\""
    end
  end
end
