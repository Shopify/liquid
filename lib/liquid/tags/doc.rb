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
  class Doc < Comment
    TAG_NAME = "doc"
  end
end
