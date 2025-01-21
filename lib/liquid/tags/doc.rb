# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category syntax
  # @liquid_name doc
  # @liquid_summary
  #   Documents template elements with annotations.
  # @liquid_description
  #   The `doc` tag allows developers to include documentation within Liquid
  #   templates. Any content inside `doc` tags is not rendered or outputted.
  #   Liquid code inside will be parsed but not executed. This facilitates
  #   tooling support for features like code completion, linting, and inline
  #   documentation.
  # @liquid_syntax
  #   {% doc %}
  #     Renders a message.
  #
  #     @param {string} foo - A foo value.
  #     @param {string} [bar] - An optional bar value.
  #
  #     @example
  #     {% render 'message', foo: 'Hello', bar: 'World' %}
  #   {% enddoc %}
  #   {{ foo }}, {{ bar }}!
  class Doc < Block
    def render_to_output_buffer(_context, output)
      output
    end

    def unknown_tag(_tag, _markup, _tokens)
    end

    def blank?
      true
    end

    def parse_body(body, tokenizer)
      while (token = tokenizer.send(:shift))
        tag_name = if tokenizer.for_liquid_tag
          next if token.empty? || token.match?(BlockBody::WhitespaceOrNothing)

          tag_name_match = BlockBody::LiquidTagToken.match(token)

          next if tag_name_match.nil?

          tag_name_match[1]
        else
          token =~ BlockBody::FullToken
          Regexp.last_match(2)
        end

        raise_nested_doc_error if tag_name == "doc"

        if tag_name == "enddoc"
          parse_context.trim_whitespace = (token[-3] == WhitespaceControl) unless tokenizer.for_liquid_tag
          return false
        end
      end

      raise_tag_never_closed(block_name)
    end

    private

    def raise_nested_doc_error
      raise SyntaxError, parse_context.locale.t("errors.syntax.doc_invalid_nested")
    end
  end
end
