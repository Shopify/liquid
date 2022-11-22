# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category syntax
  # @liquid_name comment
  # @liquid_summary
  #   Prevents an expression from being rendered or output.
  # @liquid_description
  #   Any text inside `comment` tags won't be output, and any Liquid code will be parsed, but not executed.
  # @liquid_syntax
  #   {% comment %}
  #     content
  #   {% endcomment %}
  # @liquid_syntax_keyword content The content of the comment.
  class Comment < Block
    def self.migrate(tag_name, _markup, tokenizer, parse_context)
      new_markup = "" # markup was ignored
      new_body = migrate_body(tag_name, tokenizer, parse_context)
      [new_markup, new_body]
    end

    def self.migrate_body(start_tag_name, tokenizer, parse_context)
      result = +""
      loop do
        new_body, delimiter_tag = super(start_tag_name, tokenizer, parse_context)
        result << new_body
        break unless delimiter_tag

        result << delimiter_tag.original_tag_string # unknown tags allowed
      end
      result
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
