# frozen_string_literal: true

module Liquid
  class Comment < Block
    # Potential fix
    FullTokenPossiblyInvalid = /\A(.*)#{TagStart}#{WhitespaceControl}?\s*(\w+)\s*(.*)?#{WhitespaceControl}?#{TagEnd}\z/om

    def parse(tokens)
      while (token = tokens.shift)
        if token =~ FullTokenPossiblyInvalid && block_delimiter == Regexp.last_match(2)
          return
        end
      end

      raise_tag_never_closed(block_name)
    end

    def render_to_output_buffer(_context, output)
      output
    end

    def unknown_tag(_tag, _markup, _tokens)
    end

    def blank?
      true
    end
  end

  Template.register_tag('comment', Comment)
end
