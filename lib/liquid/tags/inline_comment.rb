# frozen_string_literal: true

module Liquid
  class InlineComment < Tag
    def initialize(tag_name, markup, options)
      super
      # Semantically, a comment should only ignore everything after it on the line.
      # Currently, this implementation doesn't support mixing a comment with another tag
      # but we need to reserve future support for this.
      if markup.match?(/\n\s*[^#]/)
        raise SyntaxError, options[:locale].t("errors.syntax.inline_comment_invalid")
      end
    end

    def render_to_output_buffer(_context, output)
      output
    end

    def blank?
      true
    end
  end

  Template.register_tag('#', InlineComment)
end
