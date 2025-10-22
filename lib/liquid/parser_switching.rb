# frozen_string_literal: true

module Liquid
  module ParserSwitching
    # Do not use this.
    #
    # It's basically doing the same thing the {#parse_with_selected_parser},
    # except this will try the strict parser regardless of the error mode,
    # and fall back to the lax parser if the error mode is lax or warn,
    # except when in rigid mode where it uses the rigid parser.
    #
    # @deprecated Use {#parse_with_selected_parser} instead.
    def strict_parse_with_error_mode_fallback(markup)
      return rigid_parse_with_error_context(markup) if rigid_mode?

      strict_parse_with_error_context(markup)
    rescue SyntaxError => e
      case parse_context.error_mode
      when :rigid
        raise
      when :strict
        raise
      when :warn
        parse_context.warnings << e
      end
      lax_parse(markup)
    end

    def parse_with_selected_parser(markup)
      case parse_context.error_mode
      when :rigid  then rigid_parse_with_error_context(markup)
      when :strict then strict_parse_with_error_context(markup)
      when :lax    then lax_parse(markup)
      when :warn
        begin
          rigid_parse_with_error_context(markup)
        rescue SyntaxError => e
          parse_context.warnings << e
          lax_parse(markup)
        end
      end
    end

    def rigid_mode?
      parse_context.error_mode == :rigid
    end

    private

    def rigid_parse_with_error_context(markup)
      rigid_parse(markup)
    rescue SyntaxError => e
      e.line_number    = line_number
      e.markup_context = markup_context(markup)
      raise e
    end

    def strict_parse_with_error_context(markup)
      strict_parse(markup)
    rescue SyntaxError => e
      e.line_number    = line_number
      e.markup_context = markup_context(markup)
      raise e
    end

    def markup_context(markup)
      "in \"#{markup.strip}\""
    end
  end
end
