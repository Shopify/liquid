# frozen_string_literal: true

module Liquid
  module ParserSwitching
    def parse_with_selected_parser(markup)
      parse_markup(markup)
    rescue SyntaxError => e
      e.line_number    = line_number
      e.markup_context = markup_context(markup)
      raise e
    end

    private

    def markup_context(markup)
      "in \"#{markup.strip}\""
    end
  end
end
