# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category syntax
  # @liquid_name raw
  # @liquid_summary
  #   Outputs any Liquid code as text instead of rendering it.
  # @liquid_syntax
  #   {% raw %}
  #     expression
  #   {% endraw %}
  # @liquid_syntax_keyword expression The expression to be output without being rendered.
  class Raw < Block
    Syntax = /\A\s*\z/

    def initialize(tag_name, markup, parse_context)
      super

      ensure_valid_markup(tag_name, markup, parse_context)
    end

    def parse(tokens)
      @body = +''
      while (token = tokens.shift)
        if token =~ BlockBody::FullTokenPossiblyInvalid && block_delimiter == Regexp.last_match(2)
          parse_context.trim_whitespace = (token[-3] == WhitespaceControl)
          @body << Regexp.last_match(1) if Regexp.last_match(1) != ""
          return
        end
        @body << token unless token.empty?
      end

      raise_tag_never_closed(block_name)
    end

    def render_to_output_buffer(_context, output)
      output << @body
      output
    end

    def nodelist
      [@body]
    end

    def blank?
      @body.empty?
    end

    protected

    def ensure_valid_markup(tag_name, markup, parse_context)
      unless Syntax.match?(markup)
        raise SyntaxError, parse_context.locale.t("errors.syntax.tag_unexpected_args", tag: tag_name)
      end
    end
  end
end
