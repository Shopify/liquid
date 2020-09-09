# frozen_string_literal: true

module Liquid
  class Document
    def self.parse(tokens, parse_context)
      doc = new(parse_context)
      doc.parse(tokens, parse_context)
      doc
    end

    attr_reader :parse_context, :body

    def initialize(parse_context)
      @parse_context = parse_context
      @body = new_body
    end

    def nodelist
      @body.nodelist
    end

    def parse(tokens, parse_context)
      @body.parse(tokens, parse_context) do |end_tag_name, _end_tag_params|
        unknown_tag(end_tag_name, parse_context) if end_tag_name
      end
    rescue SyntaxError => e
      e.line_number ||= parse_context.line_number
      raise
    end

    def unknown_tag(tag, parse_context)
      case tag
      when 'else', 'end'
        raise SyntaxError, parse_context.locale.t("errors.syntax.unexpected_outer_tag", tag: tag)
      else
        raise SyntaxError, parse_context.locale.t("errors.syntax.unknown_tag", tag: tag)
      end
    end

    def render_to_output_buffer(context, output)
      @body.render_to_output_buffer(context, output)
    end

    def render(context)
      @body.render(context)
    end

    private

    def new_body
      parse_context.new_block_body
    end
  end
end
