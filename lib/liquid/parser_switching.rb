# frozen_string_literal: true

module Liquid
  module ParserSwitching
    def parse_with_selected_parser(markup)
      strict2_parse_with_error_context(markup)
    end

    private

    def strict2_parse_with_error_context(markup)
      strict2_parse(markup)
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
