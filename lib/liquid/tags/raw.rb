# frozen_string_literal: true

module Liquid
  class Raw < Block
    Syntax = /\A\s*\z/
    FullTokenPossiblyInvalid = /\A(.*)#{TagStart}\s*(\w+)\s*(.*)?#{TagEnd}\z/om

    def initialize(tag_name, markup, parse_context)
      super

      ensure_valid_markup(tag_name, markup, parse_context)
    end

    def parse(tokens)
      tokens.for_raw_tag = true
      super
    ensure
      tokens.for_raw_tag = false
    end

    def render_to_output_buffer(context, output)
      @body.render_to_output_buffer(context, output)
    end

    def nodelist
      [@body]
    end

    def unknown_tag(tag, markup, tokens)
      # no-op
    end

    protected

    def ensure_valid_markup(tag_name, markup, parse_context)
      unless Syntax.match?(markup)
        raise SyntaxError, parse_context.locale.t("errors.syntax.tag_unexpected_args", tag: tag_name)
      end
    end
  end

  Template.register_tag('raw', Raw)
end
