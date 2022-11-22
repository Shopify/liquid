# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category variable
  # @liquid_name capture
  # @liquid_summary
  #   Creates a new variable with a string value.
  # @liquid_description
  #   You can create complex strings with Liquid logic and variables.
  # @liquid_syntax
  #   {% capture variable %}
  #     value
  #   {% endcapture %}
  # @liquid_syntax_keyword variable The name of the variable being created.
  # @liquid_syntax_keyword value The value you want to assign to the variable.
  class Capture < Block
    Syntax = /(#{VariableSignature}+)/o

    def self.migrate(tag_name, markup, tokenizer, parse_context)
      match = markup.match(Syntax)

      new_markup = match[1]

      # replace scanned over characters with a space to ensure there is a space
      # to separate the tag name and the variable name
      new_markup.prepend(" ") if match.begin(0) > 0

      new_body, unknown_tag = migrate_body(tag_name, tokenizer, parse_context)
      raise SyntaxError if unknown_tag

      [new_markup, new_body]
    end

    def initialize(tag_name, markup, options)
      super
      if markup =~ Syntax
        @to = Regexp.last_match(1)
      else
        raise SyntaxError, options[:locale].t("errors.syntax.capture")
      end
    end

    def render_to_output_buffer(context, output)
      context.resource_limits.with_capture do
        capture_output = render(context)
        context.scopes.last[@to] = capture_output
      end
      output
    end

    def blank?
      true
    end
  end

  Template.register_tag('capture', Capture)
end
