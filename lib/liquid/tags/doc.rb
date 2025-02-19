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
    TAG_UNEXPECTED_ARGS = /\A\s*\z/

    def initialize(tag_name, markup, parse_context)
      super
      ensure_valid_markup(tag_name, markup, parse_context)
    end

    def parse(tokens)
      while (token = tokens.shift)
        tag_name = token =~ BlockBody::FullTokenPossiblyInvalid && Regexp.last_match(2)

        raise_nested_doc_error if tag_name == @tag_name

        if tag_name == block_delimiter
          parse_context.trim_whitespace = (token[-3] == WhitespaceControl)
          return
        end
      end

      raise_tag_never_closed(block_name)
    end

    def render_to_output_buffer(_context, output)
      output
    end

    def blank?
      true
    end

    private

    def ensure_valid_markup(tag_name, markup, parse_context)
      unless TAG_UNEXPECTED_ARGS.match?(markup)
        raise SyntaxError, parse_context.locale.t("errors.syntax.block_tag_unexpected_args", tag: tag_name)
      end
    end

    def raise_nested_doc_error
      raise SyntaxError, parse_context.locale.t("errors.syntax.doc_invalid_nested")
    end
  end
end
